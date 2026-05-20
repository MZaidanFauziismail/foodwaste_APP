@extends('layouts.app')

@section('title', 'Beranda')

@section('content')
<section class="space-y-4">

    <div class="flex items-center gap-1 text-xs font-semibold text-slate-500">
        <span class="text-purple-600">📍</span>
        <span>Alam Sutera, Tangerang · Radius 2 km</span>
    </div>

    <form method="GET" action="{{ route('feed') }}">
        <div class="rounded-2xl bg-slate-100 px-4 py-3">
            <input
                type="search"
                name="q"
                value="{{ request('q') }}"
                placeholder="Cari makanan (misal: soto ayam, nasi goreng)..."
                class="w-full bg-transparent text-xs font-semibold text-slate-600 outline-none placeholder:text-slate-400"
            >
        </div>

        <input type="hidden" name="sort" value="{{ $sort ?? 'terbaru' }}">
    </form>

    <div class="flex gap-2 overflow-x-auto pb-1">
        <a
            href="{{ route('feed', ['sort' => 'semua']) }}"
            class="shrink-0 rounded-full bg-[#6d3df5] px-4 py-2 text-xs font-extrabold text-white"
        >
            Semua
        </a>

        <span class="shrink-0 rounded-full bg-white px-4 py-2 text-xs font-bold text-slate-400 shadow-sm">
            Makanan
        </span>

        <span class="shrink-0 rounded-full bg-white px-4 py-2 text-xs font-bold text-slate-400 shadow-sm">
            Bahan Baku
        </span>

        <span class="shrink-0 rounded-full bg-white px-4 py-2 text-xs font-bold text-slate-400 shadow-sm">
            Diskon
        </span>
    </div>

    @if(isset($posts) && $posts->isEmpty())
        <div class="rounded-[24px] border border-slate-100 bg-white p-6 text-center shadow-sm">
            <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-2xl bg-[#f4efe4] text-3xl">
                🍱
            </div>

            <h2 class="mt-4 text-base font-extrabold text-slate-950">
                Belum ada makanan
            </h2>

            <p class="mt-2 text-xs leading-5 text-slate-500">
                Belum ada postingan di radius kamu. Coba buat postingan baru.
            </p>

            <a
                href="{{ route('posts.create') }}"
                class="mt-5 flex w-full items-center justify-center rounded-full bg-[#6d3df5] px-4 py-3 text-xs font-extrabold text-white"
            >
                Bagikan Makanan
            </a>
        </div>
    @endif

    <div class="grid grid-cols-2 gap-3">
        @if(isset($posts))
            @foreach($posts as $post)
                @php
                    $icons = ['🍞', '🥦', '🍰', '🍋', '🍱', '🥗'];
                    $userName = optional($post->user)->name ?? 'User';
                    $initial = strtoupper(substr($userName, 0, 1));
                @endphp

                <article class="overflow-hidden rounded-[18px] border border-slate-100 bg-white shadow-sm">
                    <a href="{{ route('posts.show', $post) }}" class="block">

                        <div class="flex h-[118px] items-center justify-center overflow-hidden bg-[#eee8db]">
                            @if($post->photo_path)
                                <img
                                    src="{{ asset('storage/' . $post->photo_path) }}"
                                    alt="{{ $post->title }}"
                                    class="h-full w-full object-cover"
                                >
                            @else
                                <div class="text-4xl">
                                    {{ $icons[$loop->index % count($icons)] }}
                                </div>
                            @endif
                        </div>

                        <div class="p-3">
                            <h2 class="line-clamp-2 min-h-[32px] text-xs font-extrabold leading-4 text-slate-950">
                                {{ $post->title }}
                            </h2>

                            <p class="mt-1 text-[10px] font-medium text-slate-400">
                                @if(isset($post->distance))
                                    {{ round($post->distance, 1) }} km
                                @else
                                    0.5 km
                                @endif
                            </p>

                            <div class="mt-3 flex items-center justify-between gap-2">
                                <div class="flex min-w-0 items-center gap-2">
                                    <span class="flex h-6 w-6 shrink-0 items-center justify-center rounded-full bg-emerald-100 text-[9px] font-extrabold text-emerald-600">
                                        {{ $initial }}
                                    </span>

                                    <span class="truncate text-[9px] font-semibold text-slate-500">
                                        {{ $userName }}
                                    </span>
                                </div>

                                <span class="shrink-0 rounded-full bg-emerald-50 px-2 py-1 text-[9px] font-extrabold text-emerald-600">
                                    {{ $post->label === 'Harga Diskon' ? 'Deal' : 'Free' }}
                                </span>
                            </div>
                        </div>
                    </a>
                </article>
            @endforeach
        @endif
    </div>
</section>
@endsection