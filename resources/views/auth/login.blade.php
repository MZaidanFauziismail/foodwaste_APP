@extends('layouts.app')

@section('title', 'Log In')

@section('content')
    <div class="card" style="max-width: 520px; margin: 0 auto;">
        <h2>Log In</h2>
        <p class="help-text">Masukkan email dan password untuk akses feed makanan lokal.</p>

        <form method="POST" action="{{ route('login.submit') }}">
            @csrf
            <div class="input-group">
                <label class="input-label" for="email">Email</label>
                <input id="email" type="email" name="email" value="{{ old('email') }}" required autofocus>
            </div>
            <div class="input-group">
                <label class="input-label" for="password">Password</label>
                <input id="password" type="password" name="password" required>
            </div>
            <div style="display:flex; gap:1rem; align-items:center; margin-top:1rem;">
                <button type="submit" class="button button-primary">Masuk</button>
                <a href="{{ route('register') }}" class="button button-secondary">Belum punya akun?</a>
            </div>
        </form>
    </div>
@endsection
