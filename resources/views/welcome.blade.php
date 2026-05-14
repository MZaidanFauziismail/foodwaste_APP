@extends('layouts.app')

@section('title', 'Selamat Datang')

@section('content')
<section class="flex min-h-[70vh] items-center">
    <div class="relative w-full overflow-hidden rounded-[32px] border border-purple-100 bg-white p-7 shadow-2xl shadow-purple-200/60">
        <div class="absolute -right-16 -top-16 h-44 w-44 rounded-full bg-purple-300/40"></div>
        <div class="absolute -bottom-20 -left-20 h-48 w-48 rounded-full bg-emerald-200/40"></div>

        <div class="relative">
            <p class="mb-5 inline-flex rounded-full bg-purple-100 px-3 py-2 text-xs font-bold text-purple-800">
                Pintu Masuk: Onboarding & Autentikasi
            </p>

            <h1 class="text-4xl font-extrabold leading-tight tracking-tight text-slate-950">
                Selamat datang di Food Waste App
            </h1>

            <p class="mt-4 text-sm leading-6 text-slate-600">
                Aplikasi lokal untuk berbagi makanan sisa secara gratis atau dengan harga diskon.
                Bangun komunitas hyper-local, temukan makanan dekatmu, dan kurangi sampah makanan bersama tetangga.
            </p>

            <div class="mt-7 grid gap-3">
                <a href="{{ route('register') }}" class="flex items-center justify-center rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700">
                    Sign Up
                </a>

                <a href="{{ route('login') }}" class="flex items-center justify-center rounded-full border border-purple-300 bg-white px-6 py-4 text-sm font-bold text-purple-800 transition hover:bg-purple-50">
                    Log In
                </a>
            </div>
        </div>
    </div>
</section>
@endsection