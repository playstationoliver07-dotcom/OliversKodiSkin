#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <version>" >&2
  echo "Example: $0 2.0.3" >&2
  exit 1
fi

NEW_VERSION="$1"
if [[ ! "$NEW_VERSION" =~ ^[0-9]+(\.[0-9]+){1,3}$ ]]; then
  echo "Version must look like 2.0.3" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADDON_XML="$ROOT_DIR/skin.bingie/addon.xml"

if [[ ! -f "$ADDON_XML" ]]; then
  echo "Could not find $ADDON_XML" >&2
  exit 1
fi

CURRENT_VERSION="$(
  grep -m1 '<addon id="skin.bingie"' "$ADDON_XML" | sed -E 's/.*version="([^"]+)".*/\1/'
)"
if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Could not read current version from $ADDON_XML" >&2
  exit 1
fi

sed -i '' -E '/<addon id="skin\.bingie"/ s/version="[^"]+"/version="'"$NEW_VERSION"'"/' "$ADDON_XML"
echo "Updated skin.bingie version: $CURRENT_VERSION -> $NEW_VERSION"
