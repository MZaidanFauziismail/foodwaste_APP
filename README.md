# EcoShare Fullstack ML v2

Aplikasi Flutter + ExpressJS + PostgreSQL + Machine Learning dengan style Olio-like.

## Update v2
- Menu garis tiga sudah bisa dibuka dari Home/Search/Community/Messages.
- Tombol + diperkecil dan otomatis hilang saat keyboard search terbuka.
- Chat terasa online dengan auto refresh 3 detik di chat dan 5 detik di list pesan.
- Dua akun bisa testing sebagai pemberi dan penerima makanan.
- Notifikasi in-app untuk request dan pesan baru.
- Location memakai permission Android via geolocator, fallback tetap tersedia jika izin ditolak.
- My Listings sudah bisa dibuka dari drawer.
- Backend root `/` sudah menampilkan status API, bukan error.

## Akun Demo
Semua password: `password`

- `demo@ecoshare.local` — penerima/requester
- `naya@ecoshare.local` — pemilik makanan
- `raka@ecoshare.local` — pemilik barang non-food

## Jalankan backend + database
```bash
cd ecoshare_fullstack_ml
docker compose down -v
docker compose up --build
```

Gunakan `docker compose down -v` sekali saja agar database lama di-reset dan tabel notifications masuk.

Cek:
```bash
curl http://localhost:3000/health
```

## Jalankan ke HP fisik
Pastikan HP dan Mac satu jaringan, lalu cari IP Mac:
```bash
ipconfig getifaddr en0
```

Contoh IP: `10.118.69.4`

```bash
cd ecoshare_fullstack_ml/frontend
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.118.69.4:3000/api
```

Atau pakai helper:
```bash
./RUN_FLUTTER_PHONE.sh http://10.118.69.4:3000/api
```

## Build APK
```bash
cd ecoshare_fullstack_ml
./BUILD_APK.sh http://10.118.69.4:3000/api
```

APK ada di:
```text
frontend/build/app/outputs/flutter-apk/app-release.apk
```

Untuk APK final tanpa localhost, deploy backend dan PostgreSQL ke cloud, lalu build:
```bash
./BUILD_APK.sh https://nama-backend-online.com/api
```

## Skenario testing 2 akun
1. Login HP 1 sebagai `naya@ecoshare.local`.
2. Login HP 2 atau Chrome sebagai `demo@ecoshare.local`.
3. Akun demo buka listing `Roti tawar sealed`, klik `Request / Chat owner`.
4. Akun Naya buka Messages, chat muncul otomatis.
5. Balas dari Naya, akun demo akan melihat pesan masuk dengan auto refresh.

## Firebase Auth + FCM version

Versi ini sudah ditambah mode Firebase Auth opsional. Lihat panduan lengkap di:

```text
README_FIREBASE.md
```

Build mode lama/local tetap bisa dipakai tanpa Firebase. Untuk mode Firebase, build APK dengan `BUILD_APK_FIREBASE.sh` atau command `flutter build apk` yang ada di README_FIREBASE.
