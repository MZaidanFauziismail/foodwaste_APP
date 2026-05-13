@extends('layouts.app')

@section('title', 'Profil & Pengaturan')

@section('content')
    <div class="card" style="max-width: 760px; margin: 0 auto;">
        <h2>Profil & Pengaturan</h2>
        <p class="help-text">Atur radius pencarian, keyword notifikasi, dan mode tema UI.</p>

        <form method="POST" action="{{ route('profile.update') }}">
            @csrf
            @method('PUT')

            <div class="input-group">
                <label class="input-label">Nama</label>
                <input type="text" value="{{ auth()->user()->name }}" disabled>
            </div>
            <div class="input-group">
                <label class="input-label">Email</label>
                <input type="email" value="{{ auth()->user()->email }}" disabled>
            </div>

            <div class="input-group">
                <label class="input-label" for="radius_km">Radius Pencarian (km)</label>
                <input id="radius_km" name="radius_km" type="number" min="1" max="50" value="{{ old('radius_km', auth()->user()->radius_km) }}" required>
            </div>

            <div class="input-group">
                <label class="input-label" for="notification_keyword">Keyword Notifikasi</label>
                <input id="notification_keyword" name="notification_keyword" type="text" value="{{ old('notification_keyword', auth()->user()->notification_keyword) }}" placeholder="Contoh: Roti">
                <p class="help-text">Anda akan diberi alert jika ada postingan baru mengandung kata ini.</p>
            </div>

            <button class="button button-primary" type="submit">Simpan Pengaturan</button>
        </form>

        <div class="card" style="margin-top:1.5rem;">
            <h3>Tema UI</h3>
            <p class="help-text">Pilih cara tampil antarmuka ketika menggunakan aplikasi.</p>
            <button id="toggle-theme" class="button button-secondary" type="button">Ganti Mode</button>
        </div>

        <div class="card" style="margin-top:1.5rem;">
            <h3>Profil Singkat</h3>
            <p><strong>Radius saat ini:</strong> {{ auth()->user()->radius_km }} km</p>
            <p><strong>Keyword alert:</strong> {{ auth()->user()->notification_keyword ?: 'Tidak ada' }}</p>
            <p><strong>Mode tema:</strong> {{ auth()->user()->theme_mode }}</p>
        </div>
    </div>

    <script>
        document.getElementById('toggle-theme')?.addEventListener('click', () => {
            const current = document.documentElement.dataset.theme;
            const next = current === 'dark' ? 'light' : 'dark';
            document.documentElement.dataset.theme = next;
            localStorage.setItem('theme', next);
            fetch('{{ route('profile.theme') }}', {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                },
                body: JSON.stringify({ theme: next }),
            });
        });
    </script>
@endsection
