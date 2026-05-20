@extends('layouts.app')

@section('title', 'Atur Lokasi')

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
                Lokasi Saya
            </p>

            <h1 class="text-3xl font-extrabold leading-tight tracking-tight text-slate-950">
                Atur lokasi pengambilan
            </h1>

            <p class="mt-3 text-sm leading-6 text-slate-600">
                Gunakan lokasi saat ini agar feed makanan dapat menampilkan postingan yang paling dekat dengan kamu.
            </p>
        </div>
    </div>

    <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
        <div class="flex items-start justify-between gap-3">
            <div>
                <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                    Status Lokasi
                </p>

                <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                    Lokasi tersimpan
                </h2>
            </div>

            <span
                id="location-badge"
                class="rounded-full bg-purple-100 px-3 py-1.5 text-xs font-bold text-purple-800"
            >
                {{ auth()->user()->latitude && auth()->user()->longitude ? 'Aktif' : 'Belum aktif' }}
            </span>
        </div>

        <div class="mt-5 grid grid-cols-2 gap-3">
            <div class="rounded-2xl bg-purple-50/70 p-4">
                <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                    Latitude
                </p>

                <p id="lat-text" class="mt-1 truncate text-sm font-extrabold text-slate-950">
                    {{ auth()->user()->latitude ?? '-' }}
                </p>
            </div>

            <div class="rounded-2xl bg-purple-50/70 p-4">
                <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                    Longitude
                </p>

                <p id="lng-text" class="mt-1 truncate text-sm font-extrabold text-slate-950">
                    {{ auth()->user()->longitude ?? '-' }}
                </p>
            </div>
        </div>

        <p id="accuracy-text" class="mt-3 text-xs leading-5 text-slate-500">
            Akurasi: {{ auth()->user()->location_accuracy ? round(auth()->user()->location_accuracy) . ' meter' : 'Belum tersedia' }}
        </p>
    </div>

    <div class="overflow-hidden w-full bg-white">
        <div id="map" class="h-[360px] w-full"></div>
    </div>

    <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
        <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
            Pilih Lokasi
        </p>

        <h2 class="mt-2 text-xl font-extrabold text-slate-950">
            Gunakan lokasi otomatis
        </h2>

        <p class="mt-2 text-sm leading-6 text-slate-600">
            Klik tombol di bawah untuk mengambil lokasi dari perangkat. Kamu juga bisa mengetuk area peta untuk memindahkan pin.
        </p>

        <div class="mt-5 grid grid-cols-1 gap-3">
            <button
                id="use-current-location"
                type="button"
                class="w-full rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
            >
                Gunakan Lokasi Saya
            </button>

            <form method="POST" action="{{ route('location.update') }}" id="location-form">
                @csrf

                <input
                    type="hidden"
                    name="latitude"
                    id="latitude"
                    value="{{ old('latitude', auth()->user()->latitude) }}"
                >

                <input
                    type="hidden"
                    name="longitude"
                    id="longitude"
                    value="{{ old('longitude', auth()->user()->longitude) }}"
                >

                <input
                    type="hidden"
                    name="accuracy"
                    id="accuracy"
                    value="{{ old('accuracy', auth()->user()->location_accuracy) }}"
                >

                <button
                    id="save-location"
                    type="submit"
                    class="w-full rounded-full border border-purple-300 bg-white px-6 py-4 text-sm font-bold text-purple-800 transition hover:bg-purple-50"
                >
                    Simpan Lokasi
                </button>
            </form>

            <a
                href="{{ route('feed') }}"
                class="flex w-full items-center justify-center rounded-full border border-slate-200 bg-white px-6 py-4 text-sm font-bold text-slate-700 transition hover:bg-slate-50"
            >
                Kembali ke Feed
            </a>
        </div>
    </div>
</section>

<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>

<script>
    const defaultLat = -6.200000;
    const defaultLng = 106.816666;

    const savedLat = Number(@json(auth()->user()->latitude));
    const savedLng = Number(@json(auth()->user()->longitude));

    const initialLat = savedLat || defaultLat;
    const initialLng = savedLng || defaultLng;

    const latitudeInput = document.getElementById('latitude');
    const longitudeInput = document.getElementById('longitude');
    const accuracyInput = document.getElementById('accuracy');

    const latText = document.getElementById('lat-text');
    const lngText = document.getElementById('lng-text');
    const accuracyText = document.getElementById('accuracy-text');
    const locationBadge = document.getElementById('location-badge');
    const currentLocationButton = document.getElementById('use-current-location');

    const map = L.map('map', {
        zoomControl: false,
    }).setView([initialLat, initialLng], savedLat && savedLng ? 16 : 12);

    L.control.zoom({
        position: 'bottomright',
    }).addTo(map);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        maxZoom: 19,
    }).addTo(map);

    const marker = L.marker([initialLat, initialLng], {
        draggable: true,
    }).addTo(map);

    const updateLocationUI = (lat, lng, accuracy = null) => {
        latitudeInput.value = lat;
        longitudeInput.value = lng;

        if (accuracy !== null) {
            accuracyInput.value = accuracy;
        }

        latText.textContent = Number(lat).toFixed(7);
        lngText.textContent = Number(lng).toFixed(7);

        if (accuracy !== null) {
            accuracyText.textContent = `Akurasi: ${Math.round(accuracy)} meter`;
        }

        locationBadge.textContent = 'Dipilih';
        locationBadge.className = 'rounded-full bg-emerald-100 px-3 py-1.5 text-xs font-bold text-emerald-800';
    };

    marker.on('dragend', () => {
        const position = marker.getLatLng();

        updateLocationUI(position.lat, position.lng, null);
        map.setView([position.lat, position.lng], 16);
    });

    map.on('click', (event) => {
        const lat = event.latlng.lat;
        const lng = event.latlng.lng;

        marker.setLatLng([lat, lng]);
        updateLocationUI(lat, lng, null);
    });

    currentLocationButton.addEventListener('click', () => {
        if (! navigator.geolocation) {
            alert('Browser kamu tidak mendukung fitur lokasi.');
            return;
        }

        currentLocationButton.disabled = true;
        currentLocationButton.textContent = 'Mengambil lokasi...';

        navigator.geolocation.getCurrentPosition((position) => {
            const lat = position.coords.latitude;
            const lng = position.coords.longitude;
            const accuracy = position.coords.accuracy;

            marker.setLatLng([lat, lng]);
            map.setView([lat, lng], 17);

            updateLocationUI(lat, lng, accuracy);

            currentLocationButton.disabled = false;
            currentLocationButton.textContent = 'Gunakan Lokasi Saya';
        }, () => {
            currentLocationButton.disabled = false;
            currentLocationButton.textContent = 'Gunakan Lokasi Saya';

            alert('Izin lokasi ditolak. Aktifkan permission lokasi di browser untuk menggunakan fitur ini.');
        }, {
            enableHighAccuracy: true,
            timeout: 15000,
            maximumAge: 0,
        });
    });

    if (latitudeInput.value && longitudeInput.value) {
        updateLocationUI(latitudeInput.value, longitudeInput.value, accuracyInput.value || null);
    }
</script>
@endsection