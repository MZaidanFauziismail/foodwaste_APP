<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>@yield('title', 'Food Waste App')</title>

    @vite(['resources/css/app.css', 'resources/js/app.js'])
</head>

<body class="min-h-screen bg-[#f4efff] text-slate-950 antialiased">
    <div class="flex min-h-screen items-center justify-center bg-[#f4efff] px-2 py-3">
        <div class="relative h-[calc(100dvh-24px)] w-full max-w-[430px] rounded-[46px] bg-slate-950 p-[6px] shadow-2xl shadow-purple-300/60">
            <div class="relative flex h-full overflow-hidden rounded-[40px] bg-white">
                <div class="relative flex h-full w-full flex-col overflow-hidden bg-white">

                    @unless(request()->routeIs('chats.*'))
                        <header class="shrink-0 border-b border-purple-100 bg-white/90 px-4 py-4 backdrop-blur">
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
                                    <form method="POST" action="{{ route('logout') }}">
                                        @csrf

                                        <button
                                            type="submit"
                                            class="rounded-full border border-slate-200 bg-white px-4 py-2 text-xs font-bold text-slate-700"
                                        >
                                            Logout
                                        </button>
                                    </form>
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

                    <main class="{{ request()->routeIs('chats.*') ? 'flex-1 overflow-hidden' : 'flex-1 overflow-y-auto px-4 py-6 pb-32' }}">
                        @yield('content')
                    </main>

                    @auth
                        @unless(request()->routeIs('chats.*'))
                            <nav class="absolute bottom-0 left-0 right-0 z-[9999] border-t border-purple-100 bg-white/95 px-4 pb-3 pt-4 shadow-2xl backdrop-blur">
                                <a
                                    href="{{ route('posts.create') }}"
                                    class="absolute left-1/2 top-0 flex h-16 w-16 -translate-x-1/2 -translate-y-1/2 items-center justify-center rounded-full text-3xl font-bold text-white shadow-2xl shadow-purple-300/80 transition
                                    {{ request()->routeIs('posts.create')
                                        ? 'bg-purple-700 scale-105'
                                        : 'bg-purple-600'
                                    }}"
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
                                        href="{{ route('profile.index') }}"
                                        class="rounded-2xl px-2 py-2 transition
                                        {{ request()->routeIs('profile.index')
                                            ? 'text-purple-700'
                                            : 'text-slate-400 hover:text-purple-700'
                                        }}"
                                    >
                                        Profile
                                    </a>
                                </div>
                            </nav>
                        @endunless
                    @endauth

                </div>
            </div>
        </div>
    </div>
</body>
</html>