#!/usr/bin/env bash
# Promptfoo exec provider wrapper for claude CLI.
# Receives the prompt as $1 — writes to a temp file to avoid
# shell quoting issues with multiline prompts.
#
# Loads the praxis plugin skills so evals can test skill behavior.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="${SCRIPT_DIR}/../../plugins/praxis"

TMPFILE=$(mktemp)
printf '%s' "$1" > "$TMPFILE"
claude --print --plugin-dir "$PLUGIN_DIR" < "$TMPFILE"
EXIT_CODE=$?
rm -f "$TMPFILE"
exit $EXIT_CODE
