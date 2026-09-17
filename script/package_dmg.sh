#!/usr/bin/env bash
set -euo pipefail

APP_NAME="Yamazaki"
DISPLAY_NAME="Yamazaki"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")"
BUILD_STAMP="$(date +%Y%m%d-%H%M%S)"
VERSION="${1:-v$APP_VERSION-$BUILD_STAMP}"
DIST_DIR="$ROOT_DIR/dist-native"
APP_BUNDLE="$DIST_DIR/$DISPLAY_NAME.app"
INSTRUCTIONS_SOURCE="$ROOT_DIR/docs/INSTALLATION_AND_USAGE.md"
STAGING_DIR="${TMPDIR:-/tmp}/Yamazaki-dmg-staging-$BUILD_STAMP"
RW_DMG="${TMPDIR:-/tmp}/$DISPLAY_NAME-$VERSION-rw.dmg"
FINAL_DMG="$DIST_DIR/$DISPLAY_NAME-$VERSION.dmg"
VOLUME_NAME="$DISPLAY_NAME"

"$ROOT_DIR/script/build_and_run.sh" --verify >/dev/null
pkill -x "$APP_NAME" >/dev/null 2>&1 || true

if [[ ! -f "$INSTRUCTIONS_SOURCE" ]]; then
  echo "instructions file not found at $INSTRUCTIONS_SOURCE" >&2
  exit 1
fi

if [[ -e "$FINAL_DMG" ]]; then
  echo "refusing to overwrite existing DMG: $FINAL_DMG" >&2
  exit 1
fi

rm -rf "$STAGING_DIR" "$RW_DMG"
mkdir -p "$STAGING_DIR"
ditto --norsrc --noextattr "$APP_BUNDLE" "$STAGING_DIR/$DISPLAY_NAME.app"
cp "$INSTRUCTIONS_SOURCE" "$STAGING_DIR/Yamazaki-安装与使用说明.md"
ln -s /Applications "$STAGING_DIR/Applications"

/usr/bin/xattr -cr "$STAGING_DIR/$DISPLAY_NAME.app" >/dev/null 2>&1 || true
/usr/bin/codesign --force --deep --sign - "$STAGING_DIR/$DISPLAY_NAME.app"
/usr/bin/codesign --verify --deep --strict "$STAGING_DIR/$DISPLAY_NAME.app"

hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -fs HFS+ \
  -format UDRW \
  "$RW_DMG" >/dev/null

hdiutil convert "$RW_DMG" \
  -format UDZO \
  -imagekey zlib-level=9 \
  -o "$FINAL_DMG" >/dev/null

rm -rf "$STAGING_DIR" "$RW_DMG"
hdiutil verify "$FINAL_DMG" >/dev/null

echo "$FINAL_DMG"
