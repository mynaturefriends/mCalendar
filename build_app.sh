#!/bin/bash
# Builds mCalendar.app — a menubar-only macOS calendar app.
set -e

cd "$(dirname "$0")"

echo "Building release binary..."
swift build -c release

APP="mCalendar.app"
BIN=".build/release/mCalendar"

echo "Assembling $APP ..."
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS"
mkdir -p "$APP/Contents/Resources"

cp "$BIN" "$APP/Contents/MacOS/mCalendar"

cat > "$APP/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>Mini Calendar</string>
    <key>CFBundleDisplayName</key>
    <string>Mini Calendar</string>
    <key>CFBundleIdentifier</key>
    <string>me.mynaturefriends.mcalendar</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>mCalendar</string>
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
