#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKIN_ADDON_XML="$ROOT_DIR/skin.bingie/addon.xml"
OMEGA_DIR="$ROOT_DIR/omega"
SKIN_FEED_DIR="$OMEGA_DIR/skin.bingie"
REPO_ID="repository.oliverskodiskin"
REPO_VERSION="1.0.0"
REPO_FEED_DIR="$OMEGA_DIR/$REPO_ID"

if [[ ! -f "$SKIN_ADDON_XML" ]]; then
  echo "Could not find $SKIN_ADDON_XML" >&2
  exit 1
fi

ORIGIN_URL="$(git -C "$ROOT_DIR" remote get-url origin)"
if [[ -z "$ORIGIN_URL" ]]; then
  echo "Git remote origin is not set. Set it first and rerun." >&2
  exit 1
fi

if [[ "$ORIGIN_URL" =~ ^https://github.com/([^/]+)/([^/.]+)(\.git)?$ ]]; then
  GH_OWNER="${BASH_REMATCH[1]}"
  GH_REPO="${BASH_REMATCH[2]}"
else
  echo "Unsupported origin URL: $ORIGIN_URL" >&2
  echo "Use HTTPS GitHub remote format: https://github.com/<owner>/<repo>.git" >&2
  exit 1
fi

RAW_BASE_URL="https://raw.githubusercontent.com/$GH_OWNER/$GH_REPO/main/omega"
SKIN_VERSION="$(grep -m1 '<addon id="skin.bingie"' "$SKIN_ADDON_XML" | sed -E 's/.*version="([^"]+)".*/\1/')"

if [[ -z "$SKIN_VERSION" ]]; then
  echo "Could not read skin version from $SKIN_ADDON_XML" >&2
  exit 1
fi

SKIN_ZIP_PATH="$("$ROOT_DIR/scripts/build_skin_zip.sh")"
SKIN_ZIP_NAME="$(basename "$SKIN_ZIP_PATH")"

mkdir -p "$SKIN_FEED_DIR" "$REPO_FEED_DIR"

cp "$SKIN_ADDON_XML" "$SKIN_FEED_DIR/addon.xml"
cp "$SKIN_ZIP_PATH" "$SKIN_FEED_DIR/$SKIN_ZIP_NAME"
md5 -q "$SKIN_FEED_DIR/$SKIN_ZIP_NAME" > "$SKIN_FEED_DIR/$SKIN_ZIP_NAME.md5"

cat > "$SKIN_FEED_DIR/index.html" <<EOF
<html>
  <body>
    <h1>Directory listing for skin.bingie</h1>
    <hr/>
    <pre>
      <a href="../index.html">..</a>
      <a href="$SKIN_ZIP_NAME">$SKIN_ZIP_NAME</a>
      <a href="$SKIN_ZIP_NAME.md5">$SKIN_ZIP_NAME.md5</a>
    </pre>
  </body>
</html>
EOF

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

TMP_REPO_DIR="$TMP_DIR/$REPO_ID"
mkdir -p "$TMP_REPO_DIR"
cp "$ROOT_DIR/skin.bingie/resources/icon.png" "$TMP_REPO_DIR/icon.png"
cp "$ROOT_DIR/skin.bingie/resources/fanart.jpg" "$TMP_REPO_DIR/fanart.jpg"

cat > "$TMP_REPO_DIR/addon.xml" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<addon id="$REPO_ID" name="Oliver Kodi Skin Repository" provider-name="playstationoliver07-dotcom" version="$REPO_VERSION">
  <extension point="xbmc.addon.repository" name="Oliver Kodi Skin Repository">
    <requires>
      <import addon="xbmc.addon" version="12.0.0"/>
    </requires>
    <dir minversion="20.9.1">
      <info compressed="false">$RAW_BASE_URL/addons.xml</info>
      <checksum>$RAW_BASE_URL/addons.xml.md5</checksum>
      <datadir zip="true">$RAW_BASE_URL/</datadir>
    </dir>
  </extension>
  <extension point="xbmc.addon.metadata">
    <summary lang="en_GB">Oliver Kodi Skin Repository</summary>
    <description lang="en_GB">Repository for Oliver's Bingie skin builds.</description>
    <platform>all</platform>
    <assets>
      <icon>icon.png</icon>
      <fanart>fanart.jpg</fanart>
    </assets>
  </extension>
</addon>
EOF

REPO_ZIP_NAME="$REPO_ID-$REPO_VERSION.zip"
REPO_ZIP_PATH="$REPO_FEED_DIR/$REPO_ZIP_NAME"
rm -f "$REPO_ZIP_PATH"
(
  cd "$TMP_DIR"
  zip -r "$REPO_ZIP_PATH" "$REPO_ID" -x '*.DS_Store' >/dev/null
)

cp "$TMP_REPO_DIR/addon.xml" "$REPO_FEED_DIR/addon.xml"
cp "$TMP_REPO_DIR/icon.png" "$REPO_FEED_DIR/icon.png"
cp "$TMP_REPO_DIR/fanart.jpg" "$REPO_FEED_DIR/fanart.jpg"
md5 -q "$REPO_ZIP_PATH" > "$REPO_FEED_DIR/$REPO_ZIP_NAME.md5"

cat > "$REPO_FEED_DIR/index.html" <<EOF
<html>
  <body>
    <h1>Directory listing for $REPO_ID</h1>
    <hr/>
    <pre>
      <a href="../index.html">..</a>
      <a href="$REPO_ZIP_NAME">$REPO_ZIP_NAME</a>
      <a href="$REPO_ZIP_NAME.md5">$REPO_ZIP_NAME.md5</a>
    </pre>
  </body>
</html>
EOF

cat > "$OMEGA_DIR/addons.xml" <<EOF
<?xml version='1.0' encoding='UTF-8'?>
<addons>
$(sed '/^<?xml /d' "$REPO_FEED_DIR/addon.xml")

$(sed '/^<?xml /d' "$SKIN_FEED_DIR/addon.xml")
</addons>
EOF

md5 -q "$OMEGA_DIR/addons.xml" > "$OMEGA_DIR/addons.xml.md5"

echo "Feed updated:"
echo "  - $OMEGA_DIR/addons.xml"
echo "  - $REPO_FEED_DIR/$REPO_ZIP_NAME"
echo "  - $SKIN_FEED_DIR/$SKIN_ZIP_NAME"
echo
echo "Apple TV source URL:"
echo "  $RAW_BASE_URL/$REPO_ID/"
