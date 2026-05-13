@extends('layouts.app')

@section('title', 'Riwayat Saya')

@section('content')
    <div style="display:grid; gap:1rem; max-width: 860px; margin: 0 auto;">
        <div class="card">
            <h2>Riwayat Makanan yang Pernah Kubagikan</h2>
            @if($shared->isEmpty())
                <p class="help-text">Belum ada postingan yang kamu bagikan.</p>
            @else
                <div class="grid grid-2" style="gap:1rem;">
                    @foreach($shared as $post)
                        <div class="card">
                            <h3>{{ $post->title }}</h3>
                            <p class="help-text">{{ $post->location_text }} • {{ ucfirst($post->status) }}</p>
                            <p style="margin:0.75rem 0 0;">Tersedia sampai {{ $post->available_until->format('d M Y H:i') }}</p>
                            <a class="button button-secondary" href="{{ route('posts.show', $post) }}">Lihat</a>
                        </div>
                    @endforeach
                </div>
            @endif
        </div>

        <div class="card">
            <h2>Riwayat Request Saya</h2>
            @if($requests->isEmpty())
                <p class="help-text">Belum ada permintaan item yang kamu kirim.</p>
            @else
                <div class="grid grid-2" style="gap:1rem;">
                    @foreach($requests as $request)
                        <div class="card">
                            <h3>{{ $request->post->title }}</h3>
                            <p class="help-text">Status: {{ ucfirst($request->status) }}</p>
                            <p style="margin:0.75rem 0 0;">Permintaan: {{ $request->message ?: 'Tidak ada pesan' }}</p>
                            <a class="button button-secondary" href="{{ route('posts.show', $request->post) }}">Lihat Postingan</a>
                        </div>
                    @endforeach
                </div>
            @endif
        </div>
    </div>
@endsection
