@extends('layouts.app')

@section('title', 'Bagikan Makanan')

@section('content')
<section class="space-y-5">
    <div class="relative overflow-hidden rounded-[32px] border border-purple-100 bg-white p-6 shadow-2xl shadow-purple-200/60">
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
                Unggah foto, isi detail lokasi, dan tentukan waktu pengambilan.
                Postingan akan muncul di feed orang sekitar.
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
                Contoh: depan minimarket, rumah blok B, atau lobby gedung.
            </p>
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
        </div>

        <input type="hidden" name="latitude" id="latitude" value="{{ old('latitude') }}">
        <input type="hidden" name="longitude" id="longitude" value="{{ old('longitude') }}">

        <button
            type="submit"
            class="w-full rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
        >
            Posting Makanan
        </button>
    </form>
</section>

<script>
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition((pos) => {
            document.getElementById('latitude').value = pos.coords.latitude;
            document.getElementById('longitude').value = pos.coords.longitude;
        });
    }
</script>
@endsection