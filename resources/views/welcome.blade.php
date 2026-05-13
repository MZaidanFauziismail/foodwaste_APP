@extends('layouts.app')

@section('title', 'Selamat Datang')

@section('content')
    <section class="hero">
        <div>
            <span class="pill">Pintu Masuk: Onboarding & Autentikasi</span>
            <h1>Selamat datang di Food Waste App</h1>
            <p>Aplikasi lokal untuk berbagi makanan sisa secara gratis atau dengan harga diskon. Bangun komunitas hyper-local, temukan makanan dekatmu, dan kurangi sampah makanan bersama tetangga.</p>
            <div class="grid grid-2" style="max-width: 720px; gap: 1rem;">
                <a class="button button-primary" href="{{ route('register') }}">Sign Up</a>
                <a class="button button-secondary" href="{{ route('login') }}">Log In</a>
            </div>
        </div>
        <div class="card" style="min-width:280px;">
            <h2>Fitur Utama</h2>
            <ul style="padding-left: 1.25rem; margin: 0;">
                <li>Minta izin lokasi saat login untuk feed hyper-local</li>
                <li>Feed berisi posting makanan sekitar berdasarkan jarak atau waktu</li>
                <li>Posting makanan dengan foto, lokasi, label, dan jam tersedia</li>
                <li>Permintaan item dan koneksi chat/WhatsApp</li>
                <li>Profil dengan radius pencarian, keyword alert, dan tema</li>
            </ul>
        </div>
    </section>
@endsection
