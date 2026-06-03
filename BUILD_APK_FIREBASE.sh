#!/usr/bin/env bash
set -euo pipefail

API_BASE_URL="${1:-}"
FIREBASE_API_KEY="${2:-}"
FIREBASE_APP_ID="${3:-}"
FIREBASE_MESSAGING_SENDER_ID="${4:-}"
FIREBASE_PROJECT_ID="${5:-}"
FIREBASE_STORAGE_BUCKET="${6:-}"

if [[ -z "$API_BASE_URL" || -z "$FIREBASE_API_KEY" || -z "$FIREBASE_APP_ID" || -z "$FIREBASE_MESSAGING_SENDER_ID" || -z "$FIREBASE_PROJECT_ID" ]]; then
  echo "Usage: ./BUILD_APK_FIREBASE.sh <API_BASE_URL> <FIREBASE_API_KEY> <FIREBASE_APP_ID> <FIREBASE_MESSAGING_SENDER_ID> <FIREBASE_PROJECT_ID> [FIREBASE_STORAGE_BUCKET]"
  echo "Example: ./BUILD_APK_FIREBASE.sh https://ecoshare-api.example.com/api AIza... 1:123:android:abc 123 ecoshare-123.appspot.com"
  exit 1
fi

cd frontend
flutter pub get
flutter build apk --release \
  --dart-define=USE_FIREBASE_AUTH=true \
  --dart-define=USE_FIREBASE_MESSAGING=true \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=FIREBASE_API_KEY="$FIREBASE_API_KEY" \
  --dart-define=FIREBASE_APP_ID="$FIREBASE_APP_ID" \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID="$FIREBASE_MESSAGING_SENDER_ID" \
  --dart-define=FIREBASE_PROJECT_ID="$FIREBASE_PROJECT_ID" \
  --dart-define=FIREBASE_STORAGE_BUCKET="$FIREBASE_STORAGE_BUCKET"

echo "APK: frontend/build/app/outputs/flutter-apk/app-release.apk"
