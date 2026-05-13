@extends('layouts.app')

@section('title', 'Feed')

@section('content')
    <div style="display:flex; flex-wrap:wrap; gap:1rem; align-items:flex-start;">
        <div style="flex:1; min-width:320px;">
            <div class="card" style="margin-bottom:1rem;">
                <div style="display:flex; justify-content:space-between; align-items:center; gap:1rem; flex-wrap:wrap;">
                    <div>
                        <h2>Feed Makanan Lokal</h2>
                        <p class="help-text">Lihat makanan di sekitar berdasarkan jarak atau waktu posting terbaru.</p>
                    </div>
                    <form method="GET" action="{{ route('feed') }}" style="display:flex; gap:0.75rem; align-items:center;">
                        <label for="sort">Urutkan:</label>
                        <select id="sort" name="sort" onchange="this.form.submit()">
                            <option value="distance" {{ $sort === 'distance' ? 'selected' : '' }}>Jarak Terdekat</option>
                            <option value="newest" {{ $sort === 'newest' ? 'selected' : '' }}>Posting Terbaru</option>
                        </select>
                    </form>
                </div>
            </div>

            @if (!$location)
                <div class="banner">
                    Aplikasi membutuhkan izin lokasi untuk menampilkan makanan yang paling dekat dengan Anda.
                    <button id="request-loc" class="button button-primary" type="button">Izinkan Lokasi</button>
                </div>
            @endif

            @if($alerts->isNotEmpty())
                <div class="banner" style="background: rgba(248,213,12,.14); border-color: rgba(245,158,11,.25);">
                    <strong>Alert:</strong> Ada postingan baru yang cocok dengan kata kunci "{{ auth()->user()->notification_keyword }}".
                </div>
            @endif

            @if($posts->isEmpty())
                <div class="card">
                    <p>Tidak ada postingan tersedia di radius Anda saat ini. Coba perbesar radius atau tunggu postingan baru.</p>
                </div>
            @endif

            <div class="grid grid-2" style="gap:1rem;">
                @foreach($posts as $post)
                    <article class="card">
                        <img src="{{ $post->photo_path ? asset('storage/'.$post->photo_path) : 'https://via.placeholder.com/420x240?text=Food' }}" alt="{{ $post->title }}" style="width:100%; border-radius:1rem; object-fit:cover; aspect-ratio:16/9;">
                        <div style="margin-top:1rem;">
                            <div style="display:flex; justify-content:space-between; gap:0.75rem; align-items:flex-start; flex-wrap:wrap;">
                                <h3 style="margin:0;">{{ $post->title }}</h3>
                                <span class="pill">{{ $post->label }}</span>
                            </div>
                            <p class="help-text">{{ Str::limit($post->description, 80) }}</p>
                            <p style="margin:0.75rem 0 0; font-size:0.95rem; color:var(--muted);">Lokasi: {{ $post->location_text }}</p>
                            @if(isset($post->distance))
                                <p style="margin:0.35rem 0 0; font-size:0.95rem;"><strong>{{ round($post->distance) }} m</strong> dari Anda</p>
                            @endif
                            <p style="margin-top:0.5rem; color:var(--muted);">Tersedia sampai {{ $post->available_until->format('d M Y H:i') }}</p>
                            <a class="button button-primary" href="{{ route('posts.show', $post) }}" style="margin-top:0.8rem;">Lihat Detail</a>
                        </div>
                    </article>
                @endforeach
            </div>
        </div>

        <aside style="width:320px; min-width:280px;">
            <div class="card">
                <h3>Info Cepat</h3>
                <p class="help-text">Setiap postingan menunjukkan jarak dan status ketersediaan. Untuk hasil terbaik, izinkan lokasi.</p>
                <p><strong>Radius pencarian:</strong> {{ auth()->user()->radius_km }} km</p>
                <p><strong>Keyword alert:</strong> {{ auth()->user()->notification_keyword ?: 'Belum diatur' }}</p>
                <a class="button button-secondary" href="{{ route('posts.create') }}">Bagikan / Jual Makanan</a>
                <a class="button button-secondary" href="{{ route('profile.index') }}">Atur Preferensi</a>
            </div>
        </aside>
    </div>

    <script>
        const requestButton = document.getElementById('request-loc');
        const locationRoute = '{{ route('location.update') }}';

        const requestLocation = () => {
            if (!navigator.geolocation) {
                alert('Browser Anda tidak mendukung geolokasi.');
                return;
            }
            navigator.geolocation.getCurrentPosition((pos) => {
                fetch(locationRoute, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                    },
                    body: JSON.stringify({
                        latitude: pos.coords.latitude,
                        longitude: pos.coords.longitude,
                    }),
                }).then(() => {
                    window.location.reload();
                });
            }, () => {
                alert('Izin lokasi ditolak. Feed akan menampilkan postingan umum.');
            });
        };

        requestButton?.addEventListener('click', requestLocation);

        @if(!$location)
            setTimeout(requestLocation, 500);
        @endif
    </script>
@endsection
