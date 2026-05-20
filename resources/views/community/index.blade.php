@extends('layouts.app')

@section('title', 'Community')

@section('content')
<section class="space-y-5">
    <div class="relative overflow-hidden w-full bg-white px-2 py-6 sm:px-6">
        <div class="absolute -right-16 -top-16 h-44 w-44 rounded-full bg-purple-300/40"></div>
        <div class="absolute -bottom-20 -left-20 h-48 w-48 rounded-full bg-emerald-200/40"></div>

        <div class="relative">
            <p class="mb-4 inline-flex rounded-full bg-purple-100 px-3 py-2 text-xs font-bold text-purple-800">
                Community
            </p>

            <h1 class="text-3xl font-extrabold leading-tight tracking-tight text-slate-950">
                Komunitas Food Waste
            </h1>

            <p class="mt-3 text-sm leading-6 text-slate-600">
                Lihat aktivitas komunitas, anggota, dan makanan yang dibagikan oleh pengguna sekitar.
            </p>
        </div>
    </div>

    <div class="grid grid-cols-3 gap-3">
        <div class="rounded-[24px] border border-purple-100 bg-white p-4 text-center shadow-lg shadow-purple-100/60">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Member
            </p>

            <p class="mt-2 text-2xl font-extrabold text-slate-950">
                {{ $totalMembers }}
            </p>
        </div>

        <div class="rounded-[24px] border border-purple-100 bg-white p-4 text-center shadow-lg shadow-purple-100/60">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Posts
            </p>

            <p class="mt-2 text-2xl font-extrabold text-slate-950">
                {{ $totalPosts }}
            </p>
        </div>

        <div class="rounded-[24px] border border-purple-100 bg-white p-4 text-center shadow-lg shadow-purple-100/60">
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Active
            </p>

            <p class="mt-2 text-2xl font-extrabold text-slate-950">
                {{ $availablePosts }}
            </p>
        </div>
    </div>

    <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
        <div class="flex items-center justify-between gap-3">
            <div>
                <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                    Members
                </p>

                <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                    Anggota Komunitas
                </h2>
            </div>
        </div>

        <div class="mt-5 space-y-3">
            @forelse($members as $member)
                <div class="flex items-center gap-3 rounded-[22px] bg-purple-50/70 p-3">
                    <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-full bg-purple-600 text-sm font-extrabold text-white shadow-lg shadow-purple-200">
                        {{ strtoupper(substr($member->name, 0, 1)) }}
                    </div>

                    <div class="min-w-0 flex-1">
                        <p class="truncate text-sm font-extrabold text-slate-950">
                            {{ $member->name }}
                        </p>

                        <p class="mt-1 truncate text-xs text-slate-500">
                            {{ $member->email }}
                        </p>
                    </div>

                    @if($member->id === auth()->id())
                        <span class="rounded-full bg-emerald-100 px-3 py-1 text-xs font-bold text-emerald-700">
                            Saya
                        </span>
                    @endif
                </div>
            @empty
                <p class="text-sm text-slate-500">
                    Belum ada anggota komunitas.
                </p>
            @endforelse
        </div>
    </div>

    <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
        <div>
            <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                Recent Activity
            </p>

            <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                Aktivitas Terbaru
            </h2>

            <p class="mt-2 text-sm leading-6 text-slate-600">
                Postingan makanan terbaru dari komunitas.
            </p>
        </div>

        <div class="mt-5 space-y-4">
            @forelse($recentPosts as $post)
                <article class="overflow-hidden rounded-[24px] border border-purple-100 bg-white shadow-lg shadow-purple-100/60">
                    <div class="flex gap-3 p-3">
                        @if($post->photo_path)
                            <img
                                src="{{ asset('storage/' . $post->photo_path) }}"
                                alt="{{ $post->title }}"
                                class="h-20 w-20 shrink-0 rounded-2xl object-cover"
                            >
                        @else
                            <div class="flex h-20 w-20 shrink-0 items-center justify-center rounded-2xl bg-purple-100 text-2xl">
                                🍱
                            </div>
                        @endif

                        <div class="min-w-0 flex-1">
                            <div class="flex items-center gap-2">
                                <span class="rounded-full bg-purple-100 px-2 py-1 text-[10px] font-bold text-purple-800">
                                    {{ $post->label }}
                                </span>

                                <span class="rounded-full bg-slate-100 px-2 py-1 text-[10px] font-bold text-slate-500">
                                    {{ ucfirst($post->status) }}
                                </span>
                            </div>

                            <h3 class="mt-2 truncate text-sm font-extrabold text-slate-950">
                                {{ $post->title }}
                            </h3>

                            <p class="mt-1 line-clamp-2 text-xs leading-5 text-slate-500">
                                {{ $post->location_text }}
                            </p>

                            <a
                                href="{{ route('posts.show', $post) }}"
                                class="mt-2 inline-flex text-xs font-bold text-purple-700"
                            >
                                Lihat Detail
                            </a>
                        </div>
                    </div>
                </article>
            @empty
                <div class="rounded-[24px] bg-purple-50/70 p-5 text-center">
                    <div class="mx-auto flex h-14 w-14 items-center justify-center rounded-full bg-purple-100 text-2xl">
                        🌱
                    </div>

                    <h3 class="mt-4 text-lg font-extrabold text-slate-950">
                        Belum ada aktivitas
                    </h3>

                    <p class="mt-2 text-sm leading-6 text-slate-600">
                        Aktivitas komunitas akan muncul setelah pengguna mulai membagikan makanan.
                    </p>
                </div>
            @endforelse
        </div>
    </div>
</section>
@endsection