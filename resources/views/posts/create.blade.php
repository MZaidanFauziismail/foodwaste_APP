@extends('layouts.app')

@section('title', 'Bagikan Makanan')

@section('content')
    <div class="card" style="max-width: 700px; margin: 0 auto;">
        <h2>Bagikan atau Jual Makanan</h2>
        <p class="help-text">Unggah foto, isi detail lokasi dan jam pengambilan. Posting akan muncul di feed orang sekitar.</p>

        <form method="POST" action="{{ route('posts.store') }}" enctype="multipart/form-data">
            @csrf

            <div class="input-group">
                <label class="input-label" for="title">Judul</label>
                <input id="title" name="title" type="text" value="{{ old('title') }}" required>
            </div>

            <div class="input-group">
                <label class="input-label" for="description">Deskripsi</label>
                <textarea id="description" name="description" rows="4">{{ old('description') }}</textarea>
            </div>

            <div class="input-group">
                <label class="input-label" for="location_text">Lokasi Pengambilan</label>
                <input id="location_text" name="location_text" type="text" value="{{ old('location_text') }}" required>
                <p class="help-text">Contoh: Lobi Apartemen X, depan minimarket, atau rumah blok B.</p>
            </div>

            <div class="grid grid-2" style="gap:1rem;">
                <div class="input-group">
                    <label class="input-label" for="available_until">Jam Ketersediaan</label>
                    <input id="available_until" name="available_until" type="datetime-local" value="{{ old('available_until') }}" required>
                </div>
                <div class="input-group">
                    <label class="input-label" for="label">Label</label>
                    <select id="label" name="label" required>
                        <option value="Gratis" {{ old('label') === 'Gratis' ? 'selected' : '' }}>Gratis</option>
                        <option value="Harga Diskon" {{ old('label') === 'Harga Diskon' ? 'selected' : '' }}>Harga Diskon</option>
                    </select>
                </div>
            </div>

            <div class="input-group">
                <label class="input-label" for="photo">Foto Makanan</label>
                <input id="photo" type="file" name="photo" accept="image/*" required>
                <p class="help-text">Ambil foto langsung atau unggah dari galeri.</p>
            </div>

            <input type="hidden" name="latitude" id="latitude" value="{{ old('latitude') }}">
            <input type="hidden" name="longitude" id="longitude" value="{{ old('longitude') }}">

            <button class="button button-primary" type="submit">Posting</button>
        </form>
    </div>

    <script>
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition((pos) => {
                document.getElementById('latitude').value = pos.coords.latitude;
                document.getElementById('longitude').value = pos.coords.longitude;
            });
        }
    </script>
@endsection
