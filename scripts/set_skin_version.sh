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
  perl -ne 'if (/<addon\b[^>]*\bid="skin\.bingie"[^>]*\bversion="([^"]+)"/) { print "$1\n"; exit }' "$ADDON_XML"
)"
if [[ -z "$CURRENT_VERSION" ]]; then
  echo "Could not read current version from $ADDON_XML" >&2
  exit 1
fi

perl -0777 -i '' -pe "s@(<addon\\b[^>]*\\bid=\"skin\\.bingie\"[^>]*\\bversion=\")[^\"]+(\"[^>]*>)@\\1$NEW_VERSION\\2@" "$ADDON_XML"
echo "Updated skin.bingie version: $CURRENT_VERSION -> $NEW_VERSION"
