#!/usr/bin/env bash
#
# check-a11y-reference-drift.sh: Report upstream changes to the files that the
# praxis research accessibility references were adapted from.
#
# Usage: check-a11y-reference-drift.sh <path-to-upstream-clone> [upstream-ref]
#
# For each file in plugins/praxis/skills/research/references/accessibility/, reads
# the "Upstream commit" and the "Upstream files" lines from its source block, then
# asks the clone which of those files changed between the pinned commit and
# upstream-ref (default: upstream/main, falling back to origin/main, then HEAD).
#
# Report only. Exit 0 when no drift, 1 when any upstream file changed, 2 on
# usage or setup errors. Nothing is edited. A person reads each diff and decides.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly REF_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)/plugins/praxis/skills/research/references/accessibility"

if [[ $# -lt 1 ]]; then
    echo "usage: $0 <path-to-upstream-clone> [upstream-ref]" >&2
    exit 2
fi

readonly CLONE="$1"
if ! git -C "${CLONE}" rev-parse --git-dir >/dev/null 2>&1; then
    echo "error: ${CLONE} is not a git repository" >&2
    exit 2
fi

if [[ $# -ge 2 ]]; then
    TARGET="$2"
elif git -C "${CLONE}" rev-parse --verify -q upstream/main >/dev/null; then
    TARGET="upstream/main"
elif git -C "${CLONE}" rev-parse --verify -q origin/main >/dev/null; then
    TARGET="origin/main"
else
    TARGET="HEAD"
fi

TARGET_SHA="$(git -C "${CLONE}" rev-parse --short "${TARGET}")"
echo "Comparing against ${TARGET} (${TARGET_SHA}) in ${CLONE}"
echo

DRIFTED=0
CHECKED=0

for file in "${REF_DIR}"/*.md; do
    name="$(basename "${file}")"
    pinned="$(sed -n 's/^> \*\*Upstream commit:\*\* `\([0-9a-f]\{7,40\}\)`.*/\1/p' "${file}" | head -n 1)"
    paths="$(sed -n 's/^> - `\([^`]*\)`.*/\1/p' "${file}")"

    # Files with no source block (INDEX.md and README.md) have nothing to check.
    if [[ -z "${pinned}" || -z "${paths}" ]]; then
        continue
    fi
    CHECKED=$(( CHECKED + 1 ))

    if ! git -C "${CLONE}" cat-file -e "${pinned}^{commit}" 2>/dev/null; then
        echo "UNKNOWN  ${name}: pinned commit ${pinned:0:7} is not in the clone (fetch it)"
        DRIFTED=$(( DRIFTED + 1 ))
        continue
    fi

    changed=""
    while IFS= read -r path; do
        [[ -z "${path}" ]] && continue
        if [[ -n "$(git -C "${CLONE}" diff --name-only "${pinned}" "${TARGET}" -- "${path}")" ]]; then
            changed+="    ${path}"$'\n'
        fi
    done <<< "${paths}"

    if [[ -n "${changed}" ]]; then
        echo "DRIFT    ${name} (pinned ${pinned:0:7}):"
        printf '%s' "${changed}"
        DRIFTED=$(( DRIFTED + 1 ))
    else
        echo "ok       ${name} (pinned ${pinned:0:7})"
    fi
done

echo
if [[ ${CHECKED} -eq 0 ]]; then
    echo "error: no reference files with a source block found in ${REF_DIR}" >&2
    exit 2
fi
if [[ ${DRIFTED} -eq 0 ]]; then
    echo "no drift in ${CHECKED} files"
    exit 0
fi
echo "${DRIFTED} of ${CHECKED} files need review"
exit 1
