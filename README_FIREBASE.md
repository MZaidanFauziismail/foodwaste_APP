# EcoShare v3 — Firebase Auth + ExpressJS + PostgreSQL

Versi ini memakai arsitektur:

```text
Flutter APK
  → Firebase Auth untuk login/register
  → ExpressJS API untuk business logic
  → PostgreSQL untuk data utama
  → Firebase Cloud Messaging opsional untuk push notification
```

## 1. Buat Firebase Project

1. Buka Firebase Console.
2. Create project.
3. Masuk **Authentication → Sign-in method**.
4. Enable **Email/Password**.
5. Masuk **Project settings → General → Your apps → Android app**.
6. Package name Android project ini:

```text
com.ecoshare.app
```

Catat nilai berikut dari Firebase app config:

```text
apiKey
appId
messagingSenderId
projectId
storageBucket
```

## 2. Buat Service Account untuk Backend

Firebase Console:

```text
Project settings → Service accounts → Generate new private key
```

Simpan file JSON service account. Untuk deploy, ubah ke base64:

```bash
base64 -i serviceAccountKey.json | pbcopy
```

Kalau command itu tidak cocok di Mac kamu, pakai:

```bash
cat serviceAccountKey.json | base64 | pbcopy
```

## 3. Environment Variables Backend

Di Railway/Render/VPS, isi env backend:

```env
NODE_ENV=production
AUTH_SECRET=isi_bebas_untuk_fallback_local
CORS_ORIGIN=*
PUBLIC_BASE_URL=https://URL-BACKEND-KAMU
DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/DB?sslmode=require
FIREBASE_PROJECT_ID=project-id-kamu
FIREBASE_SERVICE_ACCOUNT_BASE64=hasil_base64_service_account
FIREBASE_MESSAGING_ENABLED=true
```

Kalau database kamu sudah pernah dibuat sebelum v3, jalankan migrasi ini di PostgreSQL:

```sql
-- backend/database/migration_firebase.sql
ALTER TABLE users ADD COLUMN IF NOT EXISTS firebase_uid TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS auth_provider VARCHAR(30) NOT NULL DEFAULT 'local';
ALTER TABLE users ADD COLUMN IF NOT EXISTS fcm_token TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS users_firebase_uid_idx ON users (firebase_uid) WHERE firebase_uid IS NOT NULL;
```

Kalau database baru, cukup jalankan:

```bash
psql "$DATABASE_URL" -f backend/database/schema.sql
psql "$DATABASE_URL" -f backend/database/seed.sql
```

## 4. Buat Akun Testing Firebase

Di folder backend:

```bash
cd backend
npm install
npm run firebase:seed-users
```

Akun testing:

```text
demo@ecoshare.local / password
naya@ecoshare.local / password
raka@ecoshare.local / password
```

## 5. Build APK dengan Firebase Auth

Contoh build APK release:

```bash
cd frontend
flutter pub get
flutter build apk --release \
  --dart-define=USE_FIREBASE_AUTH=true \
  --dart-define=USE_FIREBASE_MESSAGING=true \
  --dart-define=API_BASE_URL=https://URL-BACKEND-KAMU/api \
  --dart-define=FIREBASE_API_KEY=apiKey_kamu \
  --dart-define=FIREBASE_APP_ID=appId_kamu \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=messagingSenderId_kamu \
  --dart-define=FIREBASE_PROJECT_ID=projectId_kamu \
  --dart-define=FIREBASE_STORAGE_BUCKET=storageBucket_kamu
```

APK akan muncul di:

```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

## 6. Testing 2 Akun

1. HP 1 login sebagai `demo@ecoshare.local`.
2. HP 2 login sebagai `naya@ecoshare.local`.
3. Akun demo request listing milik Naya.
4. Akun Naya buka Messages dan balas.
5. Chat tersimpan di PostgreSQL, auth diverifikasi oleh Firebase, dan notifikasi in-app tetap berjalan.

Catatan: FCM push notification memerlukan perangkat Android asli dan backend dengan `FIREBASE_MESSAGING_ENABLED=true` serta service account valid.
