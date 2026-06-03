# EcoShare Flutter Frontend

Frontend ini memakai style yang sama dengan `ecoshare_app_only_ready.zip`, tetapi sudah diarahkan ke backend ExpressJS.

## Run emulator

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

## Run HP fisik

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://IP_LAPTOP:3000/api
```

Contoh:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```
