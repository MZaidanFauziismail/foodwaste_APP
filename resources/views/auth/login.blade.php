@extends('layouts.app')

@section('title', 'Log In')

@section('content')
<section class="flex min-h-[70vh] items-center">
    <div class="relative w-full overflow-hidden rounded-[32px] border border-purple-100 bg-white p-7 shadow-2xl shadow-purple-200/60">
        <div class="absolute -right-16 -top-16 h-44 w-44 rounded-full bg-purple-300/40"></div>
        <div class="absolute -bottom-20 -left-20 h-48 w-48 rounded-full bg-emerald-200/40"></div>

        <div class="relative">
            <p class="mb-4 inline-flex rounded-full bg-purple-100 px-3 py-2 text-xs font-bold text-purple-800">
                Masuk ke Akun
            </p>

            <h1 class="text-3xl font-extrabold leading-tight tracking-tight text-slate-950">
                Selamat datang kembali
            </h1>

            <p class="mt-3 text-sm leading-6 text-slate-600">
                Masukkan email dan password untuk akses feed makanan lokal di sekitar kamu.
            </p>

            <form method="POST" action="{{ route('login.submit') }}" class="mt-7 space-y-5">
                @csrf

                <div>
                    <label for="email" class="mb-2 block text-sm font-bold text-slate-700">
                        Email
                    </label>

                    <input
                        id="email"
                        type="email"
                        name="email"
                        value="{{ old('email') }}"
                        required
                        autofocus
                        placeholder="contoh@email.com"
                        class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
                    >
                </div>

                <div>
                    <label for="password" class="mb-2 block text-sm font-bold text-slate-700">
                        Password
                    </label>

                    <input
                        id="password"
                        type="password"
                        name="password"
                        required
                        placeholder="Masukkan password"
                        class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
                    >
                </div>

                <button
                    type="submit"
                    class="w-full rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
                >
                    Masuk
                </button>

                <a
                    href="{{ route('register') }}"
                    class="flex w-full items-center justify-center rounded-full border border-purple-300 bg-white px-6 py-4 text-sm font-bold text-purple-800 transition hover:bg-purple-50"
                >
                    Belum punya akun? Daftar
                </a>
            </form>
        </div>
    </div>
</section>
@endsection