@extends('layouts.app')

@section('title', $post->title)

@section('content')
@php
    $isOwner = $post->user_id === auth()->id();
    $isAvailable = $post->status === 'available';
    $owner = $post->owner;
    $ownerName = $owner?->name ?? 'Pengguna';
@endphp

<section class="space-y-5">
    <div class="overflow-hidden rounded-[32px] border border-purple-100 bg-white shadow-2xl shadow-purple-200/60">
        <div class="relative">
            @if($post->photo_path)
                <img
                    src="{{ asset('storage/' . $post->photo_path) }}"
                    alt="{{ $post->title }}"
                    class="aspect-[4/3] w-full object-cover"
                >
            @else
                <div class="flex aspect-[4/3] w-full items-center justify-center bg-gradient-to-br from-amber-100 via-orange-50 to-purple-100">
                    <div class="flex h-24 w-24 items-center justify-center rounded-[32px] bg-white/80 text-5xl shadow-xl">
                        🍱
                    </div>
                </div>
            @endif

            <a
                href="{{ route('feed') }}"
                class="absolute left-4 top-4 flex h-10 w-10 items-center justify-center rounded-full bg-white/90 text-lg font-extrabold text-slate-800 shadow-lg backdrop-blur"
            >
                ←
            </a>

            <span class="absolute right-4 top-4 rounded-full bg-white/90 px-3 py-1.5 text-xs font-extrabold text-purple-800 shadow-lg backdrop-blur">
                {{ $post->label }}
            </span>
        </div>

        <div class="p-5">
            <div class="flex flex-wrap gap-2">
                <span class="rounded-full bg-emerald-100 px-3 py-1.5 text-xs font-bold text-emerald-700">
                    {{ $post->label }}
                </span>

                <span class="rounded-full bg-purple-100 px-3 py-1.5 text-xs font-bold text-purple-700">
                    Food
                </span>

                <span class="rounded-full bg-blue-100 px-3 py-1.5 text-xs font-bold text-blue-700">
                    Lokal
                </span>
            </div>

            <h1 class="mt-4 text-2xl font-extrabold leading-tight tracking-tight text-slate-950">
                {{ $post->title }}
            </h1>

            <div class="mt-4 flex items-center gap-3 border-b border-purple-100 pb-4">
                <div class="flex h-12 w-12 items-center justify-center rounded-full bg-emerald-100 text-sm font-extrabold text-emerald-700">
                    {{ strtoupper(substr($ownerName, 0, 1)) }}
                </div>

                <div>
                    <p class="text-sm font-extrabold text-slate-950">
                        {{ $ownerName }}
                    </p>

                    <p class="mt-1 text-xs font-medium text-slate-500">
                        Membagikan makanan ini
                    </p>
                </div>
            </div>

            <div class="mt-5 space-y-5">
                <div>
                    <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                        Description
                    </p>

                    <p class="mt-2 text-sm leading-6 text-slate-700">
                        {{ $post->description ?: 'Tidak ada deskripsi tambahan.' }}
                    </p>
                </div>

                <div>
                    <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                        Collection Details
                    </p>

                    <div class="mt-2 space-y-3">
                        <div class="rounded-2xl bg-purple-50/70 p-4">
                            <p class="text-sm font-bold text-slate-950">
                                Tersedia sampai
                            </p>

                            <p class="mt-1 text-sm text-slate-600">
                                {{ $post->available_until->format('d M Y H:i') }}
                            </p>
                        </div>

                        <div class="rounded-2xl bg-purple-50/70 p-4">
                            <p class="text-sm font-bold text-slate-950">
                                Status
                            </p>

                            <p class="mt-1 text-sm text-slate-600">
                                {{ ucfirst($post->status) }}
                            </p>
                        </div>
                    </div>
                </div>

                <div>
                    <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                        Location
                    </p>

                    <div class="mt-2 rounded-2xl bg-purple-50/70 p-4">
                        <p class="text-sm font-bold text-slate-950">
                            {{ $post->location_text }}
                        </p>

                        @if($post->latitude && $post->longitude)
                            <p class="mt-1 text-sm text-slate-600">
                                Koordinat: {{ $post->latitude }}, {{ $post->longitude }}
                            </p>
                        @else
                            <p class="mt-1 text-sm text-slate-600">
                                Lokasi detail digunakan untuk proses pengambilan makanan.
                            </p>
                        @endif
                    </div>
                </div>

                <div class="rounded-2xl border border-amber-200 bg-amber-50 p-4 text-xs leading-5 text-amber-900">
                    Pastikan makanan masih layak dikonsumsi. Cek kondisi makanan, waktu tersedia, dan detail lokasi sebelum mengambil.
                </div>
            </div>
        </div>
    </div>

    @if(!$isOwner && $isAvailable)
        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Request Item
            </p>

            <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                Tertarik dengan makanan ini?
            </h2>

            <p class="mt-2 text-sm leading-6 text-slate-600">
                Kirim pesan singkat ke pemilik makanan untuk menanyakan ketersediaan atau mengajukan permintaan.
            </p>

            <form method="POST" action="{{ route('posts.request', $post) }}" class="mt-5 space-y-4">
                @csrf

                <div>
                    <label for="message" class="mb-2 block text-sm font-bold text-slate-700">
                        Pesan permintaan
                    </label>

                    <textarea
                        id="message"
                        name="message"
                        rows="4"
                        placeholder="Halo kak, makanannya masih tersedia?"
                        class="w-full resize-none rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
                    >{{ old('message') }}</textarea>
                </div>

                <button
                    type="submit"
                    class="w-full rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
                >
                    Request Item
                </button>
            </form>

            @if($owner)
                <a
                    href="{{ route('chats.show', [$post, $owner]) }}"
                    class="mt-3 flex w-full items-center justify-center rounded-full border border-purple-300 bg-white px-6 py-4 text-sm font-bold text-purple-800 transition hover:bg-purple-50"
                >
                    Chat Pemilik
                </a>
            @endif
        </div>
    @endif

    @if($isOwner && $isAvailable)
        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Postingan Milikmu
            </p>

            <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                Kelola postingan ini
            </h2>

            <p class="mt-2 text-sm leading-6 text-slate-600">
                Jika makanan sudah diambil, tandai postingan agar tidak tampil sebagai tersedia.
            </p>

            <form method="POST" action="{{ route('posts.markTaken', $post) }}" class="mt-5">
                @csrf

                <button
                    type="submit"
                    class="w-full rounded-full bg-red-500 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-red-200 transition hover:bg-red-600"
                >
                    Tandai Sudah Diambil
                </button>
            </form>
        </div>
    @endif

    @if(!$isAvailable)
        <div class="rounded-[28px] border border-slate-200 bg-slate-50 p-5 text-center">
            <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-slate-200 text-2xl">
                ✅
            </div>

            <h2 class="mt-4 text-xl font-extrabold text-slate-950">
                Makanan sudah tidak tersedia
            </h2>

            <p class="mt-2 text-sm leading-6 text-slate-600">
                Postingan ini sudah ditandai sebagai {{ ucfirst($post->status) }}.
            </p>

            <a
                href="{{ route('feed') }}"
                class="mt-5 flex w-full items-center justify-center rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
            >
                Kembali ke Feed
            </a>
        </div>
    @endif
</section>
@endsection
