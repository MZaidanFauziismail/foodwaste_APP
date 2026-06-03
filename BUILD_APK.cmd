@echo off
cd frontend
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
mkdir ..\APK_OUTPUT 2>nul
copy build\app\outputs\flutter-apk\app-release.apk ..\APK_OUTPUT\EcoShare-Fullstack-release.apk
echo APK created at APK_OUTPUT\EcoShare-Fullstack-release.apk
