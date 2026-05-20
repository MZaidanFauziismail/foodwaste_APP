<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>@yield('title', 'Food Waste App')</title>

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="min-h-screen bg-white text-slate-950 antialiased">
    <div class="relative flex min-h-screen w-full flex-col overflow-x-hidden bg-white">

        @unless(request()->routeIs('chats.*'))
            <header class="shrink-0 border-b border-purple-100 bg-white/90 px-4 pt-12 pb-4 backdrop-blur">
                <div class="flex items-center justify-between gap-3">
                    <a
                        href="{{ auth()->check() ? route('feed') : url('/') }}"
                        class="text-lg font-extrabold tracking-tight text-slate-950"
                    >
                        Food Waste
                    </a>

                    @guest
                        <div class="flex items-center gap-2">
                            <a
                                href="{{ route('register') }}"
                                class="rounded-full bg-purple-600 px-4 py-2 text-xs font-bold text-white shadow-lg shadow-purple-200"
                            >
                                Sign Up
                            </a>

                            <a
                                href="{{ route('login') }}"
                                class="rounded-full border border-slate-200 bg-white px-4 py-2 text-xs font-bold text-slate-700"
                            >
                                Log In
                            </a>
                        </div>
                    @endguest

                    @auth
                        <div class="flex items-center gap-2">
                            <a
                                href="{{ route('profile.index') }}"
                                class="flex h-10 w-10 items-center justify-center rounded-full bg-purple-600 text-sm font-extrabold text-white shadow-lg shadow-purple-200 ring-4 ring-purple-100"
                                title="Buka Profil"
                            >
                                {{-- DIUBAH: Menggunakan mb_ untuk keamanan multi-byte character (PHP 8.4) --}}
                                {{ mb_strtoupper(mb_substr(auth()->user()->name, 0, 1, 'UTF-8'), 'UTF-8') }}
                            </a>

                            <form method="POST" action="{{ route('logout') }}">
                                @csrf

                                <button
                                    type="submit"
                                    class="rounded-full border border-slate-200 bg-white px-3 py-2 text-xs font-bold text-slate-700"
                                >
                                    Logout
                                </button>
                            </form>
                        </div>
                    @endauth
                </div>
            </header>
        @endunless

        @if(session('success'))
            <div class="mx-4 mt-4 rounded-2xl border border-emerald-200 bg-emerald-50 px-4 py-3 text-sm font-semibold text-emerald-800">
                {{ session('success') }}
            </div>
        @endif

        @if($errors->any())
            <div class="mx-4 mt-4 rounded-2xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-800">
                <ul class="list-disc pl-5">
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        {{-- PERBAIKAN: Menambahkan pt-14 dan px-4 agar konten chat tidak menabrak status bar HP --}}
        <main class="{{ request()->routeIs('chats.*') ? 'flex-1 overflow-hidden pt-14 px-4' : 'flex-1 overflow-y-auto px-4 py-6 pb-32' }}">
            @yield('content')
        </main>

        @auth
            @unless(request()->is('chats/*'))
                {{-- DIUBAH: Dari absolute ke fixed agar menempel di layar mobile saat di-scroll --}}
                <nav class="fixed bottom-0 left-0 right-0 z-[9999] border-t border-purple-100 bg-white/95 px-4 pb-8 pt-4 shadow-2xl backdrop-blur">
                    <a
                        href="{{ route('posts.create') }}"
                        class="absolute left-1/2 top-0 flex h-16 w-16 -translate-x-1/2 -translate-y-1/2 items-center justify-center rounded-full text-3xl font-bold text-white shadow-2xl shadow-purple-300/80 transition {{ request()->routeIs('posts.create') ? 'bg-purple-700 scale-105' : 'bg-purple-600' }}"
                    >
                        +
                    </a>

                    <div class="grid grid-cols-4 gap-2 text-center text-[11px] font-bold">
                        <a
                            href="{{ route('feed') }}"
                            class="rounded-2xl px-2 py-2 transition
                            {{ request()->routeIs('feed')
                                ? 'text-purple-700'
                                : 'text-slate-400 hover:text-purple-700'
                            }}"
                        >
                            Feed
                        </a>

                        <a
                            href="{{ route('posts.create') }}"
                            class="rounded-2xl px-2 py-2 transition
                            {{ request()->routeIs('posts.create')
                                ? 'text-purple-700'
                                : 'text-slate-400 hover:text-purple-700'
                            }}"
                        >
                            Share
                        </a>

                        <a
                            href="{{ route('profile.history') }}"
                            class="rounded-2xl px-2 py-2 transition
                            {{ request()->routeIs('profile.history')
                                ? 'text-purple-700'
                                : 'text-slate-400 hover:text-purple-700'
                            }}"
                        >
                            History
                        </a>

                        <a
                            href="{{ route('community.index') }}"
                            class="rounded-2xl px-2 py-2 transition
                            {{ request()->routeIs('community.*')
                                ? 'text-purple-700'
                                : 'text-slate-400 hover:text-purple-700'
                            }}"
                        >
                            Community
                        </a>
                    </div>
                </nav>
            @endunless
        @endauth

    </div>
</body>
</html>