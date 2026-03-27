#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ADDON_DIR="$ROOT_DIR/skin.bingie"
ADDON_XML="$ADDON_DIR/addon.xml"
OUT_DIR="$ROOT_DIR/dist"

if [[ ! -f "$ADDON_XML" ]]; then
  echo "Could not find $ADDON_XML" >&2
  exit 1
fi

VERSION="$(
  grep -m1 '<addon id="skin.bingie"' "$ADDON_XML" | sed -E 's/.*version="([^"]+)".*/\1/'
)"
if [[ -z "$VERSION" ]]; then
  echo "Could not read version from $ADDON_XML" >&2
  exit 1
fi

SUFFIX="${1:-}"
ZIP_NAME="skin.bingie-${VERSION}${SUFFIX:+-$SUFFIX}.zip"
ZIP_PATH="$OUT_DIR/$ZIP_NAME"

mkdir -p "$OUT_DIR"
rm -f "$ZIP_PATH"

(
  cd "$ROOT_DIR"
  zip -r "$ZIP_PATH" "skin.bingie" -x '*.DS_Store' >/dev/null
)

echo "$ZIP_PATH"
