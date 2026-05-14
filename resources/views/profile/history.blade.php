@extends('layouts.app')

@section('title', 'Riwayat Saya')

@section('content')
<section class="space-y-5">
    <div class="relative overflow-hidden rounded-[32px] border border-purple-100 bg-white p-6 shadow-2xl shadow-purple-200/60">
        <div class="absolute -right-16 -top-16 h-44 w-44 rounded-full bg-purple-300/40"></div>
        <div class="absolute -bottom-20 -left-20 h-48 w-48 rounded-full bg-emerald-200/40"></div>

        <div class="relative">
            <p class="mb-4 inline-flex rounded-full bg-purple-100 px-3 py-2 text-xs font-bold text-purple-800">
                Riwayat
            </p>

            <h1 class="text-3xl font-extrabold leading-tight tracking-tight text-slate-950">
                Aktivitas Saya
            </h1>

            <p class="mt-3 text-sm leading-6 text-slate-600">
                Lihat riwayat makanan yang pernah kamu bagikan dan permintaan makanan yang pernah kamu kirim.
            </p>
        </div>
    </div>

    <div class="grid grid-cols-2 gap-3">
        <div class="rounded-[24px] border border-purple-100 bg-white p-4 shadow-lg shadow-purple-100/60">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Dibagikan
            </p>

            <p class="mt-2 text-2xl font-extrabold text-slate-950">
                {{ $shared->count() }}
            </p>
        </div>

        <div class="rounded-[24px] border border-purple-100 bg-white p-4 shadow-lg shadow-purple-100/60">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Request
            </p>

            <p class="mt-2 text-2xl font-extrabold text-slate-950">
                {{ $requests->count() }}
            </p>
        </div>
    </div>

    <div class="space-y-4">
        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Postinganku
            </p>

            <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                Makanan yang Pernah Kubagikan
            </h2>

            <p class="mt-2 text-sm leading-6 text-slate-600">
                Semua makanan yang pernah kamu posting akan muncul di bagian ini.
            </p>
        </div>

        @if($shared->isEmpty())
            <div class="rounded-[28px] border border-purple-100 bg-white p-6 text-center shadow-xl shadow-purple-100/70">
                <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-purple-100 text-2xl">
                    🍱
                </div>

                <h3 class="mt-4 text-xl font-extrabold text-slate-950">
                    Belum ada postingan
                </h3>

                <p class="mt-2 text-sm leading-6 text-slate-600">
                    Kamu belum pernah membagikan makanan. Mulai posting makanan supaya muncul di feed orang sekitar.
                </p>

                <a
                    href="{{ route('posts.create') }}"
                    class="mt-5 flex w-full items-center justify-center rounded-full bg-purple-600 px-5 py-3 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
                >
                    Bagikan Makanan
                </a>
            </div>
        @else
            <div class="space-y-4">
                @foreach($shared as $post)
                    <article class="overflow-hidden rounded-[28px] border border-purple-100 bg-white shadow-xl shadow-purple-100/70">
                        <div class="relative">
                            <img
                                src="{{ $post->photo_path ? asset('storage/' . $post->photo_path) : 'https://via.placeholder.com/420x240?text=Food' }}"
                                alt="{{ $post->title }}"
                                class="aspect-[16/9] w-full object-cover"
                            >

                            <span class="absolute left-4 top-4 rounded-full bg-white/90 px-3 py-1.5 text-xs font-extrabold text-purple-800 shadow-lg backdrop-blur">
                                {{ ucfirst($post->status) }}
                            </span>
                        </div>

                        <div class="p-5">
                            <h3 class="text-xl font-extrabold leading-tight text-slate-950">
                                {{ $post->title }}
                            </h3>

                            <div class="mt-4 space-y-2 text-sm text-slate-600">
                                <p>
                                    <span class="font-bold text-slate-800">Lokasi:</span>
                                    {{ $post->location_text }}
                                </p>

                                <p>
                                    <span class="font-bold text-slate-800">Tersedia sampai:</span>
                                    {{ $post->available_until->format('d M Y H:i') }}
                                </p>

                                <p>
                                    <span class="font-bold text-slate-800">Label:</span>
                                    {{ $post->label }}
                                </p>
                            </div>

                            <a
                                href="{{ route('posts.show', $post) }}"
                                class="mt-5 flex w-full items-center justify-center rounded-full border border-purple-300 bg-white px-5 py-3 text-sm font-bold text-purple-800 transition hover:bg-purple-50"
                            >
                                Lihat Detail
                            </a>
                        </div>
                    </article>
                @endforeach
            </div>
        @endif
    </div>

    <div class="space-y-4">
        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Permintaanku
            </p>

            <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                Riwayat Request Saya
            </h2>

            <p class="mt-2 text-sm leading-6 text-slate-600">
                Semua permintaan makanan yang pernah kamu kirim akan muncul di bagian ini.
            </p>
        </div>

        @if($requests->isEmpty())
            <div class="rounded-[28px] border border-purple-100 bg-white p-6 text-center shadow-xl shadow-purple-100/70">
                <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-purple-100 text-2xl">
                    📨
                </div>

                <h3 class="mt-4 text-xl font-extrabold text-slate-950">
                    Belum ada request
                </h3>

                <p class="mt-2 text-sm leading-6 text-slate-600">
                    Kamu belum pernah mengirim permintaan makanan. Cari makanan di feed lalu kirim request.
                </p>

                <a
                    href="{{ route('feed') }}"
                    class="mt-5 flex w-full items-center justify-center rounded-full bg-purple-600 px-5 py-3 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
                >
                    Buka Feed
                </a>
            </div>
        @else
            <div class="space-y-4">
                @foreach($requests as $foodRequest)
                    <article class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
                        <div class="flex items-start justify-between gap-3">
                            <div>
                                <p class="inline-flex rounded-full bg-purple-100 px-3 py-1.5 text-xs font-bold text-purple-800">
                                    {{ ucfirst($foodRequest->status) }}
                                </p>

                                <h3 class="mt-3 text-xl font-extrabold leading-tight text-slate-950">
                                    {{ $foodRequest->post->title }}
                                </h3>
                            </div>
                        </div>

                        <div class="mt-4 space-y-2 text-sm text-slate-600">
                            <p>
                                <span class="font-bold text-slate-800">Pesan:</span>
                                {{ $foodRequest->message ?: 'Tidak ada pesan' }}
                            </p>

                            <p>
                                <span class="font-bold text-slate-800">Lokasi:</span>
                                {{ $foodRequest->post->location_text }}
                            </p>

                            <p>
                                <span class="font-bold text-slate-800">Label:</span>
                                {{ $foodRequest->post->label }}
                            </p>
                        </div>

                        <a
                            href="{{ route('posts.show', $foodRequest->post) }}"
                            class="mt-5 flex w-full items-center justify-center rounded-full border border-purple-300 bg-white px-5 py-3 text-sm font-bold text-purple-800 transition hover:bg-purple-50"
                        >
                            Lihat Postingan
                        </a>
                    </article>
                @endforeach
            </div>
        @endif
    </div>
</section>
@endsection