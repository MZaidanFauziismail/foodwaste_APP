#!/usr/bin/env bash
set -euo pipefail
API_BASE_URL="${1:-http://10.118.69.4:3000/api}"
cd "$(dirname "$0")/frontend"
flutter clean
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL="$API_BASE_URL"
echo "APK created at: frontend/build/app/outputs/flutter-apk/app-release.apk"
