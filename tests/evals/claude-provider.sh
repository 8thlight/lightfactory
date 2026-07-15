#!/usr/bin/env bash
# Promptfoo exec provider wrapper for claude CLI.
# Receives the prompt as $1 — writes to a temp file to avoid
# shell quoting issues with multiline prompts.
#
# Loads every plugin under plugins/ so evals can test any plugin's skill behavior.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGINS_ROOT="${SCRIPT_DIR}/../../plugins"

PLUGIN_DIR_ARGS=()
for plugin_dir in "${PLUGINS_ROOT}"/*/; do
    [[ -d "${plugin_dir}" ]] || continue
    PLUGIN_DIR_ARGS+=(--plugin-dir "${plugin_dir%/}")
done

TMPFILE=$(mktemp)
printf '%s' "$1" > "$TMPFILE"
claude --print "${PLUGIN_DIR_ARGS[@]}" < "$TMPFILE"
EXIT_CODE=$?
rm -f "$TMPFILE"
exit $EXIT_CODE
