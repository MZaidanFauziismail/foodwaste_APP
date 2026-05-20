@extends('layouts.app')

@section('title', 'Bagikan Makanan')

@section('content')
<link
    rel="stylesheet"
    href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
/>

<section class="space-y-5">
    <div class="relative overflow-hidden w-full bg-white px-2 py-6 sm:px-6">
        <div class="absolute -right-16 -top-16 h-44 w-44 rounded-full bg-purple-300/40"></div>
        <div class="absolute -bottom-20 -left-20 h-48 w-48 rounded-full bg-emerald-200/40"></div>

        <div class="relative">
            <p class="mb-4 inline-flex rounded-full bg-purple-100 px-3 py-2 text-xs font-bold text-purple-800">
                Bagikan Makanan
            </p>

            <h1 class="text-3xl font-extrabold leading-tight tracking-tight text-slate-950">
                Posting makanan sisa
            </h1>

            <p class="mt-3 text-sm leading-6 text-slate-600">
                Unggah foto, isi detail makanan, pilih titik lokasi pengambilan, dan tentukan waktu ketersediaan.
            </p>
        </div>
    </div>

    <form method="POST" action="{{ route('posts.store') }}" enctype="multipart/form-data" class="space-y-5">
        @csrf

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="title" class="mb-2 block text-sm font-bold text-slate-700">
                Judul Makanan
            </label>

            <input
                id="title"
                name="title"
                type="text"
                value="{{ old('title') }}"
                required
                placeholder="Contoh: Nasi box ayam"
                class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="description" class="mb-2 block text-sm font-bold text-slate-700">
                Deskripsi
            </label>

            <textarea
                id="description"
                name="description"
                rows="4"
                placeholder="Jelaskan kondisi makanan, jumlah porsi, dan informasi penting lainnya."
                class="w-full resize-none rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >{{ old('description') }}</textarea>
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="location_text" class="mb-2 block text-sm font-bold text-slate-700">
                Lokasi Pengambilan
            </label>

            <input
                id="location_text"
                name="location_text"
                type="text"
                value="{{ old('location_text') }}"
                required
                placeholder="Contoh: Lobi Apartemen X"
                class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >

            <p class="mt-2 text-xs leading-5 text-slate-500">
                Isi nama tempat yang mudah dikenali. Titik peta di bawah akan membantu pengguna menemukan lokasi.
            </p>
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <div class="flex items-start justify-between gap-3">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                        Lokasi Peta
                    </p>

                    <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                        Pilih titik pengambilan
                    </h2>
                </div>

                <span
                    id="location-badge"
                    class="rounded-full bg-amber-100 px-3 py-1.5 text-xs font-bold text-amber-800"
                >
                    Belum dipilih
                </span>
            </div>

            <p class="mt-3 text-sm leading-6 text-slate-600">
                Gunakan lokasi saat ini, cari alamat, atau geser pin pada peta.
            </p>

            <div class="mt-5 space-y-3">
                <div class="relative">
                    <input
                        id="location-search"
                        type="text"
                        placeholder="Cari alamat atau tempat..."
                        class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 pr-24 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
                    >

                    <button
                        id="search-location"
                        type="button"
                        class="absolute right-2 top-1/2 -translate-y-1/2 rounded-full bg-purple-600 px-4 py-2 text-xs font-bold text-white shadow-lg shadow-purple-200 transition hover:bg-purple-700"
                    >
                        Cari
                    </button>
                </div>

                <button
                    id="use-current-location"
                    type="button"
                    class="w-full rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
                >
                    Gunakan Lokasi Saya
                </button>
            </div>

            <div class="mt-5 overflow-hidden rounded-[26px] border border-purple-100 bg-purple-50 shadow-inner">
                <div id="map" class="h-[360px] w-full"></div>
            </div>

            <div class="mt-4 rounded-[24px] bg-purple-50/70 p-4">
                <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                    Alamat terdeteksi
                </p>

                <p id="detected-address" class="mt-2 text-sm font-semibold leading-6 text-slate-700">
                    Belum ada alamat terdeteksi.
                </p>
            </div>

            <div class="mt-4 grid grid-cols-2 gap-3">
                <div class="rounded-2xl bg-purple-50/70 p-4">
                    <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                        Latitude
                    </p>

                    <p id="lat-text" class="mt-1 truncate text-sm font-extrabold text-slate-950">
                        {{ old('latitude') ?: '-' }}
                    </p>
                </div>

                <div class="rounded-2xl bg-purple-50/70 p-4">
                    <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                        Longitude
                    </p>

                    <p id="lng-text" class="mt-1 truncate text-sm font-extrabold text-slate-950">
                        {{ old('longitude') ?: '-' }}
                    </p>
                </div>
            </div>

            <p id="accuracy-text" class="mt-3 text-xs leading-5 text-slate-500">
                Akurasi: belum tersedia
            </p>

            <input type="hidden" name="latitude" id="latitude" value="{{ old('latitude') }}">
            <input type="hidden" name="longitude" id="longitude" value="{{ old('longitude') }}">
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="available_until" class="mb-2 block text-sm font-bold text-slate-700">
                Tersedia Sampai
            </label>

            <input
                id="available_until"
                name="available_until"
                type="datetime-local"
                value="{{ old('available_until') }}"
                required
                class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="label" class="mb-2 block text-sm font-bold text-slate-700">
                Label
            </label>

            <select
                id="label"
                name="label"
                required
                class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm font-semibold text-slate-900 outline-none transition focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >
                <option value="Gratis" {{ old('label') === 'Gratis' ? 'selected' : '' }}>
                    Gratis
                </option>

                <option value="Harga Diskon" {{ old('label') === 'Harga Diskon' ? 'selected' : '' }}>
                    Harga Diskon
                </option>
            </select>
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="photo" class="mb-2 block text-sm font-bold text-slate-700">
                Foto Makanan
            </label>

            <label for="photo" class="flex cursor-pointer flex-col items-center justify-center rounded-[24px] border-2 border-dashed border-purple-200 bg-purple-50/50 px-4 py-8 text-center transition hover:bg-purple-50">
                <span class="flex h-14 w-14 items-center justify-center rounded-full bg-purple-100 text-2xl">
                    📷
                </span>

                <span class="mt-3 text-sm font-bold text-purple-800">
                    Pilih atau ambil foto
                </span>

                <span class="mt-1 text-xs leading-5 text-slate-500">
                    Upload foto makanan dari galeri atau kamera.
                </span>
            </label>

            <input
                id="photo"
                type="file"
                name="photo"
                accept="image/*"
                required
                class="sr-only"
            >

            <p id="photo-name" class="mt-3 text-xs font-semibold text-slate-500">
                Belum ada foto dipilih.
            </p>
        </div>

        <button
            type="submit"
            class="w-full rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
        >
            Posting Makanan
        </button>
    </form>
</section>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
    const defaultLat = -6.200000;
    const defaultLng = 106.816666;

    const latitudeInput = document.getElementById('latitude');
    const longitudeInput = document.getElementById('longitude');
    const locationTextInput = document.getElementById('location_text');
    const locationSearchInput = document.getElementById('location-search');
    const searchLocationButton = document.getElementById('search-location');
    const useCurrentLocationButton = document.getElementById('use-current-location');
    const detectedAddress = document.getElementById('detected-address');
    const latText = document.getElementById('lat-text');
    const lngText = document.getElementById('lng-text');
    const accuracyText = document.getElementById('accuracy-text');
    const locationBadge = document.getElementById('location-badge');
    const photoInput = document.getElementById('photo');
    const photoName = document.getElementById('photo-name');

    const oldLat = Number(latitudeInput.value);
    const oldLng = Number(longitudeInput.value);

    const initialLat = oldLat || defaultLat;
    const initialLng = oldLng || defaultLng;

    const map = L.map('map', {
        zoomControl: false,
    }).setView([initialLat, initialLng], oldLat && oldLng ? 16 : 12);

    L.control.zoom({
        position: 'bottomright',
    }).addTo(map);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
        attribution: '',
    }).addTo(map);

    const marker = L.marker([initialLat, initialLng], {
        draggable: true,
    }).addTo(map);

    const setLocationState = (lat, lng, accuracy = null, address = null) => {
        latitudeInput.value = lat;
        longitudeInput.value = lng;

        latText.textContent = Number(lat).toFixed(7);
        lngText.textContent = Number(lng).toFixed(7);

        if (accuracy !== null) {
            accuracyText.textContent = `Akurasi: ${Math.round(accuracy)} meter`;
        } else {
            accuracyText.textContent = 'Akurasi: titik dipilih manual';
        }

        if (address) {
            detectedAddress.textContent = address;

            if (!locationTextInput.value.trim()) {
                locationTextInput.value = address;
            }
        }

        locationBadge.textContent = 'Dipilih';
        locationBadge.className = 'rounded-full bg-emerald-100 px-3 py-1.5 text-xs font-bold text-emerald-800';
    };

    const reverseGeocode = async (lat, lng) => {
        detectedAddress.textContent = 'Mendeteksi alamat...';

        try {
            const response = await fetch(`https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${lat}&lon=${lng}`);
            const data = await response.json();

            const address = data.display_name || 'Alamat tidak ditemukan.';
            setLocationState(lat, lng, null, address);
        } catch (error) {
            detectedAddress.textContent = 'Alamat tidak dapat dideteksi. Silakan isi lokasi manual.';
            setLocationState(lat, lng);
        }
    };

    const moveMarker = (lat, lng, zoom = 16, accuracy = null, address = null) => {
        marker.setLatLng([lat, lng]);
        map.setView([lat, lng], zoom);
        setLocationState(lat, lng, accuracy, address);
    };

    marker.on('dragend', () => {
        const position = marker.getLatLng();

        moveMarker(position.lat, position.lng, 16);
        reverseGeocode(position.lat, position.lng);
    });

    map.on('click', (event) => {
        const lat = event.latlng.lat;
        const lng = event.latlng.lng;

        moveMarker(lat, lng, 16);
        reverseGeocode(lat, lng);
    });

    useCurrentLocationButton.addEventListener('click', () => {
        if (! navigator.geolocation) {
            alert('Browser kamu tidak mendukung fitur lokasi.');
            return;
        }

        useCurrentLocationButton.disabled = true;
        useCurrentLocationButton.textContent = 'Mengambil lokasi...';

        navigator.geolocation.getCurrentPosition((position) => {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            const accuracy = position.coords.accuracy;

            moveMarker(lat, lng, 17, accuracy);
            reverseGeocode(lat, lng);

            useCurrentLocationButton.disabled = false;
            useCurrentLocationButton.textContent = 'Gunakan Lokasi Saya';
        }, () => {
            useCurrentLocationButton.disabled = false;
            useCurrentLocationButton.textContent = 'Gunakan Lokasi Saya';

            alert('Izin lokasi ditolak. Aktifkan permission lokasi di browser untuk menggunakan fitur ini.');
        }, {
            enableHighAccuracy: true,
            timeout: 15000,
            maximumAge: 0,
        });
    });

    searchLocationButton.addEventListener('click', async () => {
        const keyword = locationSearchInput.value.trim();

        if (!keyword) {
            alert('Masukkan alamat atau nama tempat terlebih dahulu.');
            return;
        }

        searchLocationButton.disabled = true;
        searchLocationButton.textContent = '...';

        try {
            const response = await fetch(`https://nominatim.openstreetmap.org/search?format=jsonv2&q=${encodeURIComponent(keyword)}&limit=1`);
            const results = await response.json();

            if (!results.length) {
                alert('Lokasi tidak ditemukan. Coba kata kunci lain.');
                return;
            }

            const result = results[0];
            const lat = Number(result.lat);
            const lng = Number(result.lon);
            const address = result.display_name;

            moveMarker(lat, lng, 16, null, address);
        } catch (error) {
            alert('Gagal mencari lokasi. Coba lagi.');
        } finally {
            searchLocationButton.disabled = false;
            searchLocationButton.textContent = 'Cari';
        }
    });

    locationSearchInput.addEventListener('keydown', (event) => {
        if (event.key === 'Enter') {
            event.preventDefault();
            searchLocationButton.click();
        }
    });

    photoInput.addEventListener('change', () => {
        if (photoInput.files.length) {
            photoName.textContent = photoInput.files[0].name;
        } else {
            photoName.textContent = 'Belum ada foto dipilih.';
        }
    });

    if (oldLat && oldLng) {
        moveMarker(oldLat, oldLng, 16);
        reverseGeocode(oldLat, oldLng);
    }

    setTimeout(() => {
        map.invalidateSize();
    }, 300);
</script>
@endsection