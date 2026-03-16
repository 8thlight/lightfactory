#!/usr/bin/env bash
set -euo pipefail

# Bump all versions in marketplace.json by incrementing the minor version.
# 1.2.3 -> 1.3.0, 0.9.1 -> 0.10.0, etc.

MARKETPLACE_FILE=".claude-plugin/marketplace.json"

if [ ! -f "$MARKETPLACE_FILE" ]; then
  echo "Error: $MARKETPLACE_FILE not found" >&2
  exit 1
fi

bump_minor() {
  local version="$1"
  local major minor
  major=$(echo "$version" | cut -d. -f1)
  minor=$(echo "$version" | cut -d. -f2)
  echo "${major}.$((minor + 1)).0"
}

# Read current versions
marketplace_version=$(jq -r '.metadata.version' "$MARKETPLACE_FILE")
new_marketplace_version=$(bump_minor "$marketplace_version")

echo "Marketplace: $marketplace_version -> $new_marketplace_version"

# Bump marketplace version
tmp=$(mktemp)
jq --arg v "$new_marketplace_version" '.metadata.version = $v' "$MARKETPLACE_FILE" > "$tmp" && mv "$tmp" "$MARKETPLACE_FILE"

# Bump each plugin version
plugin_count=$(jq '.plugins | length' "$MARKETPLACE_FILE")
for i in $(seq 0 $((plugin_count - 1))); do
  plugin_name=$(jq -r ".plugins[$i].name" "$MARKETPLACE_FILE")
  plugin_version=$(jq -r ".plugins[$i].version" "$MARKETPLACE_FILE")
  new_plugin_version=$(bump_minor "$plugin_version")

  echo "Plugin $plugin_name: $plugin_version -> $new_plugin_version"

  tmp=$(mktemp)
  jq --argjson i "$i" --arg v "$new_plugin_version" '.plugins[$i].version = $v' "$MARKETPLACE_FILE" > "$tmp" && mv "$tmp" "$MARKETPLACE_FILE"
done

echo "Done. All versions bumped."
