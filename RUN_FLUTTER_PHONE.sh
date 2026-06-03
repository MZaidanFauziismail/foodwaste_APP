#!/usr/bin/env bash
set -euo pipefail
API_BASE_URL="${1:-http://10.118.69.4:3000/api}"
cd "$(dirname "$0")/frontend"
flutter pub get
flutter run --dart-define=API_BASE_URL="$API_BASE_URL"
