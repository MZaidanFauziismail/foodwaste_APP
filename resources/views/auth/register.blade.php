@extends('layouts.app')

@section('title', 'Sign Up')

@section('content')
    <div class="card" style="max-width: 520px; margin: 0 auto;">
        <h2>Sign Up</h2>
        <p class="help-text">Buat akun baru untuk mulai berbagi makanan atau menemukan makanan gratis di lingkunganmu.</p>

        <form method="POST" action="{{ route('register.submit') }}">
            @csrf
            <div class="input-group">
                <label class="input-label" for="name">Nama</label>
                <input id="name" type="text" name="name" value="{{ old('name') }}" required autofocus>
            </div>
            <div class="input-group">
                <label class="input-label" for="email">Email</label>
                <input id="email" type="email" name="email" value="{{ old('email') }}" required>
            </div>
            <div class="input-group">
                <label class="input-label" for="password">Password</label>
                <input id="password" type="password" name="password" required>
            </div>
            <div class="input-group">
                <label class="input-label" for="password_confirmation">Konfirmasi Password</label>
                <input id="password_confirmation" type="password" name="password_confirmation" required>
            </div>
            <div style="display:flex; gap:1rem; align-items:center; margin-top:1rem;">
                <button type="submit" class="button button-primary">Daftar</button>
                <a href="{{ route('login') }}" class="button button-secondary">Sudah punya akun?</a>
            </div>
        </form>
    </div>
@endsection
