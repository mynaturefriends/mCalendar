#!/bin/bash
# Builds a Release mCalendar.app and its distribution zip into build/.
#
# Signing degrades gracefully:
#   - "Developer ID Application" certificate in the keychain -> signed with it
#   - plus a stored notarytool profile (see NOTARY_PROFILE) -> notarized+stapled,
#     so macOS opens the download without the unidentified-developer warning
#   - neither -> ad-hoc signature; the app runs but warns on first launch
#
# One-time setup for notarization:
#   1. Xcode > Settings > Accounts > Manage Certificates > + > Developer ID Application
#   2. xcrun notarytool store-credentials mcalendar \
#          --apple-id <apple-id> --team-id <team-id> --password <app-specific-password>
set -e
cd "$(dirname "$0")/.."

NOTARY_PROFILE=mcalendar

VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" mCalendar-Info.plist)
APP="build/mCalendar.app"
ZIP="build/mCalendar-${VERSION}.zip"

IDENTITY=$(security find-identity -v -p codesigning \
    | sed -n 's/.*"\(Developer ID Application: [^"]*\)".*/\1/p' | head -1)

if [ -n "$IDENTITY" ]; then
    echo "Signing identity: $IDENTITY"
    SIGN_ARGS=(
        CODE_SIGN_IDENTITY="$IDENTITY"
        CODE_SIGN_STYLE=Manual
        OTHER_CODE_SIGN_FLAGS="--timestamp"
    )
else
    echo "No Developer ID Application certificate found -- signing ad-hoc."
    echo "The download will warn about an unidentified developer on first launch."
    SIGN_ARGS=()
fi

xcodebuild -project mCalendar.xcodeproj -scheme mCalendar \
    -configuration Release -derivedDataPath build/xcode "${SIGN_ARGS[@]}" build

mkdir -p build
rm -rf "$APP" "$ZIP"
cp -R build/xcode/Build/Products/Release/mCalendar.app build/

if [ -n "$IDENTITY" ]; then
    if xcrun notarytool history --keychain-profile "$NOTARY_PROFILE" >/dev/null 2>&1; then
        # Notarization takes the app as a zip, but the ticket is stapled to the
        # .app -- so this upload copy is thrown away and the real one rebuilt
        # afterwards, with the ticket inside.
        echo "Submitting for notarization (this usually takes a few minutes)..."
        ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"
        xcrun notarytool submit "$ZIP" --keychain-profile "$NOTARY_PROFILE" --wait
        xcrun stapler staple "$APP"
        rm -f "$ZIP"
    else
        echo "No '$NOTARY_PROFILE' notarytool profile -- skipping notarization."
        echo "Run: xcrun notarytool store-credentials $NOTARY_PROFILE ..."
    fi
fi

ditto -c -k --sequesterRsrc --keepParent "$APP" "$ZIP"

echo
echo "Done:"
echo "  $APP"
echo "  $ZIP"
echo -n "  gatekeeper: "
spctl -a -t exec -vv "$APP" 2>&1 | tail -2 | tr '\n' ' '
echo
