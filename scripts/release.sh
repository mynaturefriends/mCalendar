#!/bin/bash
# Builds a Release mCalendar.app and its distribution zip into build/.
set -e
cd "$(dirname "$0")/.."

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" mCalendar-Info.plist)

xcodebuild -project mCalendar.xcodeproj -scheme mCalendar \
    -configuration Release -derivedDataPath build/xcode build

mkdir -p build
rm -rf build/mCalendar.app "build/mCalendar-${VERSION}.zip"
cp -R build/xcode/Build/Products/Release/mCalendar.app build/
ditto -c -k --sequesterRsrc --keepParent build/mCalendar.app "build/mCalendar-${VERSION}.zip"

echo
echo "Done:"
echo "  build/mCalendar.app"
echo "  build/mCalendar-${VERSION}.zip"
