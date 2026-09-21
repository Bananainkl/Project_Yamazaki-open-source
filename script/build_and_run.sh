#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
APP_NAME="Yamazaki"
DISPLAY_NAME="Yamazaki"
BUNDLE_ID="com.itou.yamazaki"
MIN_SYSTEM_VERSION="13.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")"
DIST_DIR="$ROOT_DIR/dist-native"
ARCHIVE_DIR="$DIST_DIR/archive"
APP_BUNDLE="$DIST_DIR/$DISPLAY_NAME.app"
APP_CONTENTS="$APP_BUNDLE/Contents"
APP_MACOS="$APP_CONTENTS/MacOS"
APP_RESOURCES="$APP_CONTENTS/Resources"
APP_BINARY="$APP_MACOS/$APP_NAME"
INFO_PLIST="$APP_CONTENTS/Info.plist"
APP_ICON_SOURCE="$ROOT_DIR/Resources/AppIcon.icns"
INSTALL_BUNDLE="/Applications/$DISPLAY_NAME.app"
LAUNCHD_DOMAIN="gui/$(id -u)"
SDK_VERSION="$(/usr/bin/xcrun --sdk macosx --show-sdk-version)"
BUILD_SCRATCH="${TMPDIR:-/tmp}/YamazakiBuild-macos-$SDK_VERSION-$(uname -m)"

/bin/launchctl bootout "$LAUNCHD_DOMAIN/com.itou.yamazaki.watchdog" >/dev/null 2>&1 || true
/bin/launchctl bootout "$LAUNCHD_DOMAIN/com.itou.yamazaki.keepalive" >/dev/null 2>&1 || true
pkill -x "$APP_NAME" >/dev/null 2>&1 || true
pkill -x "FreeScanOCR" >/dev/null 2>&1 || true

swift build --scratch-path "$BUILD_SCRATCH"
BUILD_BINARY="$(swift build --scratch-path "$BUILD_SCRATCH" --show-bin-path)/$APP_NAME"

rm -rf "$APP_BUNDLE"
mkdir -p "$APP_MACOS" "$APP_RESOURCES"
cp "$BUILD_BINARY" "$APP_BINARY"
chmod +x "$APP_BINARY"
if [[ -f "$APP_ICON_SOURCE" ]]; then
  cp "$APP_ICON_SOURCE" "$APP_RESOURCES/AppIcon.icns"
fi

cat >"$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundleDisplayName</key>
  <string>$DISPLAY_NAME</string>
  <key>CFBundleShortVersionString</key>
  <string>$APP_VERSION</string>
  <key>CFBundleVersion</key>
  <string>$APP_VERSION</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MIN_SYSTEM_VERSION</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
  <key>LSUIElement</key>
  <true/>
</dict>
</plist>
PLIST

# FileProvider/Finder metadata can invalidate strict code-signature checks on macOS 27.
/usr/bin/xattr -cr "$APP_BUNDLE" >/dev/null 2>&1 || true
/usr/bin/xattr -d com.apple.FinderInfo "$APP_BUNDLE" >/dev/null 2>&1 || true
/usr/bin/xattr -d 'com.apple.fileprovider.fpfs#P' "$APP_BUNDLE" >/dev/null 2>&1 || true
/usr/bin/codesign --force --deep --sign - "$APP_BUNDLE"
/usr/bin/codesign --verify --deep --strict "$APP_BUNDLE"
/usr/bin/xattr -dr com.apple.quarantine "$APP_BUNDLE" >/dev/null 2>&1 || true

open_app() {
  /usr/bin/open -n "$APP_BUNDLE"
}

case "$MODE" in
  run)
    open_app
    ;;
  --install|install)
    mkdir -p "$ARCHIVE_DIR"
    if [[ -d "$INSTALL_BUNDLE" ]]; then
      INSTALLED_VERSION="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$INSTALL_BUNDLE/Contents/Info.plist" 2>/dev/null || echo unknown)"
      ARCHIVE_BUNDLE="$ARCHIVE_DIR/$DISPLAY_NAME-v$INSTALLED_VERSION-$(date +%Y%m%d-%H%M%S).app"
      ditto "$INSTALL_BUNDLE" "$ARCHIVE_BUNDLE"
    fi
    rm -rf "$INSTALL_BUNDLE"
    ditto --norsrc --noextattr "$APP_BUNDLE" "$INSTALL_BUNDLE"
    /usr/bin/xattr -dr com.apple.quarantine "$INSTALL_BUNDLE" >/dev/null 2>&1 || true
    /usr/bin/xattr -cr "$INSTALL_BUNDLE" >/dev/null 2>&1 || true
    /usr/bin/codesign --verify --deep --strict "$INSTALL_BUNDLE"
    /usr/bin/open "$INSTALL_BUNDLE"
    ;;
  --debug|debug)
    lldb -- "$APP_BINARY"
    ;;
  --logs|logs)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --telemetry|telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "subsystem == \"$BUNDLE_ID\""
    ;;
  --verify|verify)
    open_app
    sleep 1
    pgrep -x "$APP_NAME" >/dev/null
    ;;
  *)
    echo "usage: $0 [run|--install|--debug|--logs|--telemetry|--verify]" >&2
    exit 2
    ;;
esac
