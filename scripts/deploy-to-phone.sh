#!/bin/zsh
# Build, install and launch AHN POINT FITNESS on Coleman's iPhone, then prune
# Xcode caches so they never pile up:
#   - Device Support: keep only the folder for the iOS version the phone runs now
#   - DerivedData: drop folders whose project no longer exists, plus untitled junk
# Free 7-day profile: run this weekly (the app posts a reminder the night before).
set -u
setopt NULL_GLOB

PROJECT_DIR="${0:A:h:h}"
XCODE_ID="00008140-001E69340EE3001C"                  # xcodebuild destination id
DEVICE_ID="429CF584-E242-5366-8E9F-13A9F97F423E"      # devicectl id
BUNDLE="com.coleman.recomp"
DD="$HOME/Library/Developer/Xcode/DerivedData"

echo "▸ Phone"
# JSON, not the human-readable text: Xcode 27 renamed those labels and broke parsing.
INFO_JSON=$(mktemp)
xcrun devicectl device info details --device "$DEVICE_ID" --quiet --json-output "$INFO_JSON" >/dev/null 2>&1
VER=$(plutil -extract result.deviceProperties.osVersionNumber raw -o - "$INFO_JSON" 2>/dev/null)
BUILD=$(plutil -extract result.deviceProperties.osBuildUpdate raw -o - "$INFO_JSON" 2>/dev/null)
rm -f "$INFO_JSON"
if [[ -z "$VER" || -z "$BUILD" ]]; then
  echo "  Phone not reachable — plug it in, unlock it, and rerun."; exit 1
fi
echo "  iOS $VER ($BUILD)"

echo "▸ Prune Device Support (keeping iOS $VER only)"
for dir in "$HOME"/Library/Developer/Xcode/*DeviceSupport/*/; do
  name=${dir:h:t}; [[ "$dir" == */ ]] && name=$(basename "$dir")
  if [[ "$name" != *" $VER ($BUILD)" ]]; then
    echo "  removing $name ($(du -sh "$dir" | cut -f1))"; rm -rf "$dir"
  fi
done

echo "▸ Prune DerivedData"
for dir in "$DD"/*/; do
  name=$(basename "$dir")
  [[ "$name" == *.noindex || "$name" == SDK* ]] && continue   # Xcode's shared caches
  ws=$(/usr/libexec/PlistBuddy -c "Print :WorkspacePath" "$dir/info.plist" 2>/dev/null)
  if [[ -z "$ws" || ! -e "$ws" ]]; then
    echo "  removing $name ($(du -sh "$dir" | cut -f1))"; rm -rf "$dir"
  fi
done
echo "▸ Build"
# Default DerivedData location, shared with Xcode itself, so there is one cache.
xcodebuild -project "$PROJECT_DIR/AhnPointFitness.xcodeproj" -scheme AhnPointFitness \
  -configuration Debug -destination "platform=iOS,id=$XCODE_ID" \
  -allowProvisioningUpdates build 2>&1 | grep -E "error:|BUILD (SUCCEEDED|FAILED)" | head -5
APP=$(xcodebuild -project "$PROJECT_DIR/AhnPointFitness.xcodeproj" -scheme AhnPointFitness \
  -configuration Debug -destination "platform=iOS,id=$XCODE_ID" -showBuildSettings 2>/dev/null \
  | awk -F' = ' '/ CODESIGNING_FOLDER_PATH = / {print $2; exit}')
[[ -d "$APP" ]] || { echo "  Build failed. If the error mentions the developer disk image, Xcode is too old for iOS $VER — update Xcode in the App Store."; exit 1; }

echo "▸ Install"
xcrun devicectl device install app --device "$DEVICE_ID" "$APP" 2>&1 | grep -E "App installed|rror" | head -2

echo "▸ Launch"
for i in 1 2 3; do
  OUT=$(xcrun devicectl device process launch --device "$DEVICE_ID" --terminate-existing "$BUNDLE" 2>&1)
  if print -r -- "$OUT" | grep -q "Launched application"; then echo "  Launched."; break; fi
  if print -r -- "$OUT" | grep -q "not been explicitly trusted"; then
    echo "  Blocked: trust the profile on the phone (Settings → General → VPN & Device Management), then open the app."; break
  fi
  [[ $i == 3 ]] && print -r -- "$OUT" | grep -iE "FailureReason" | head -1
  sleep 6
done
EXP=$(security cms -D -i "$APP/embedded.mobileprovision" 2>/dev/null | plutil -extract ExpirationDate raw -o - - 2>/dev/null)
[[ -n "$EXP" ]] && echo "  Profile expires: $(date -r "$(TZ=UTC date -j -f '%Y-%m-%dT%H:%M:%SZ' "$EXP" +%s)" '+%a %b %d, %-I:%M %p %Z' 2>/dev/null || echo "$EXP")"

echo "Done."
