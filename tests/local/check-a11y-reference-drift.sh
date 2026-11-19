#!/usr/bin/env bash
#
# check-a11y-reference-drift.sh: Report upstream changes to the files that the
# praxis research accessibility references were adapted from.
#
# Usage: check-a11y-reference-drift.sh <path-to-upstream-clone> [upstream-ref]
#
# For each section of plugins/praxis/skills/research/references/accessibility/PROVENANCE.md,
# reads the "Upstream commit" line and the "Upstream files" list, then
# asks the clone which of those files changed between the pinned commit and
# upstream-ref (default: upstream/main, falling back to origin/main, then HEAD).
#
# Report only. Exit 0 when no drift, 1 when any upstream file changed, 2 on
# usage or setup errors. Nothing is edited. A person reads each diff and decides.

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROVENANCE_FILE="$(cd "${SCRIPT_DIR}/../.." && pwd)/plugins/praxis/skills/research/references/accessibility/PROVENANCE.md"

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

if [[ ! -f "${PROVENANCE_FILE}" ]]; then
    echo "error: ${PROVENANCE_FILE} not found" >&2
    exit 2
fi

# One record per "## name" section: name, pinned commit, upstream paths (tab-separated,
# paths joined by newlines encoded as ";").
records="$(awk '
    function flush() { if (name != "" && pinned != "" && paths != "") print name "\t" pinned "\t" paths }
    /^## / { flush(); name = substr($0, 4); pinned = ""; paths = ""; next }
    match($0, /^- Upstream commit: `[0-9a-f]+`/) {
        s = substr($0, RSTART, RLENGTH); sub(/^- Upstream commit: `/, "", s); sub(/`$/, "", s); pinned = s; next
    }
    match($0, /^  - `[^`]*`/) {
        s = substr($0, RSTART, RLENGTH); sub(/^  - `/, "", s); sub(/`$/, "", s)
        paths = (paths == "" ? s : paths ";" s); next
    }
    END { flush() }
' "${PROVENANCE_FILE}")"

while IFS=$'\t' read -r name pinned paths_joined; do
    [[ -z "${name}" ]] && continue
    paths="${paths_joined//;/$'\n'}"
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
done <<< "${records}"

echo
if [[ ${CHECKED} -eq 0 ]]; then
    echo "error: no sections with an upstream commit and file list found in ${PROVENANCE_FILE}" >&2
    exit 2
fi
if [[ ${DRIFTED} -eq 0 ]]; then
    echo "no drift in ${CHECKED} files"
    exit 0
fi
echo "${DRIFTED} of ${CHECKED} files need review"
exit 1
