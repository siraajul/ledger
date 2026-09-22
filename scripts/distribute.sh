#!/usr/bin/env bash
# Build a release binary and upload it to Firebase App Distribution.
# Usage: scripts/distribute.sh [android|ios]   (default: android)
set -euo pipefail
cd "$(dirname "$0")/.."

PLATFORM="${1:-android}"
TESTER_GROUPS="${TESTER_GROUPS:-internal}"
NOTES="$(git log -1 --pretty='%h %s')"

case "$PLATFORM" in
  android)
    APP_ID="1:770523884423:android:efdc7400f47cf49876c122"
    flutter build apk --release
    BINARY="build/app/outputs/flutter-apk/app-release.apk"
    ;;
  ios)
    APP_ID="1:770523884423:ios:b6e6c89603c9f87676c122"
    # Development export: only devices registered in the Apple Developer portal
    # can install. Switch to ad-hoc/enterprise if you need wider reach.
    flutter build ipa --release --export-method development
    BINARY="$(ls build/ios/ipa/*.ipa | head -1)"
    ;;
  *)
    echo "usage: $0 [android|ios]" >&2
    exit 1
    ;;
esac

npx -y firebase-tools@latest appdistribution:distribute "$BINARY" \
  --app "$APP_ID" \
  --groups "$TESTER_GROUPS" \
  --release-notes "$NOTES"
