#!/bin/bash
# Builds ZCalendar.app — a menubar-only macOS calendar app.
set -e

cd "$(dirname "$0")"

echo "Building release binary..."
swift build -c release

APP="ZCalendar.app"
BIN=".build/release/ZCalendar"

echo "Assembling $APP ..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$BIN" "$APP/Contents/MacOS/ZCalendar"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>ZCalendar</string>
    <key>CFBundleDisplayName</key>
    <string>ZCalendar</string>
    <key>CFBundleIdentifier</key>
    <string>com.z.zcalendar</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>ZCalendar</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

# Ad-hoc code signature so macOS will run it locally.
codesign --force --deep --sign - "$APP" 2>/dev/null || true

echo "Done: $(pwd)/$APP"
echo "Launch with:  open $APP"
