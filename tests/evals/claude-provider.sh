#!/usr/bin/env bash
# Promptfoo exec provider wrapper for claude CLI.
# Receives the prompt as $1 and writes it to a temp file to avoid
# shell quoting issues with multiline prompts.
#
# Loads the praxis plugin skills so evals can test skill behavior.
#
# Each call runs in a fresh empty directory outside the repo, so no
# artifacts carry over between runs and no parent CLAUDE.md or .beads/
# leaks in. Skills write artifacts to .light/ and reply with a summary,
# so any .light/**/*.md the run wrote is appended to the output for the
# assertions to read.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "${SCRIPT_DIR}/../../plugins/praxis" && pwd)"

SETTINGS=$(cat <<EOF
{"permissions":{"allow":["Skill","Read(/${PLUGIN_DIR}/**)","Glob","Grep","Write","Task","WebSearch","WebFetch"]}}
EOF
)

WORKDIR=$(mktemp -d)
TMPFILE=$(mktemp)
printf '%s' "$1" > "$TMPFILE"

(cd "$WORKDIR" && claude --print --plugin-dir "$PLUGIN_DIR" --settings "$SETTINGS" < "$TMPFILE")
EXIT_CODE=$?

if [ -d "$WORKDIR/.light" ]; then
  while IFS= read -r artifact; do
    printf '\n\n=== ARTIFACT: %s ===\n' "${artifact#"$WORKDIR"/}"
    cat "$artifact"
  done < <(find "$WORKDIR/.light" -type f -name '*.md' | sort)
fi

rm -f "$TMPFILE"
rm -rf "$WORKDIR"
exit $EXIT_CODE
