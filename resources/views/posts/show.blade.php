@extends('layouts.app')

@section('title', 'Detail Postingan')

@section('content')
    <div class="card" style="max-width: 860px; margin: 0 auto;">
        <div style="display:flex; gap:1rem; flex-wrap:wrap; align-items:flex-start;">
            <img src="{{ $post->photo_path ? asset('storage/'.$post->photo_path) : 'https://via.placeholder.com/560x320?text=Food' }}" alt="{{ $post->title }}" style="width:100%; max-width:420px; border-radius:1rem; object-fit:cover; aspect-ratio:16/9;">
            <div style="flex:1; min-width:280px;">
                <h2>{{ $post->title }}</h2>
                <span class="pill">{{ $post->label }}</span>
                <p class="help-text">Dibagikan oleh {{ $post->owner->name }}</p>
                <p style="margin:1rem 0;">{{ $post->description }}</p>
                <p><strong>Lokasi:</strong> {{ $post->location_text }}</p>
                @if($post->latitude && $post->longitude)
                    <p><strong>Koordinat:</strong> {{ $post->latitude }}, {{ $post->longitude }}</p>
                @endif
                <p><strong>Tersedia sampai:</strong> {{ $post->available_until->format('d M Y H:i') }}</p>
                <p><strong>Status:</strong> {{ ucfirst($post->status) }}</p>
                <div style="display:flex; gap:0.75rem; flex-wrap:wrap; margin-top:1rem;">
                    @if($post->user_id !== auth()->id() && $post->status === 'available')
                        <form method="POST" action="{{ route('posts.request', $post) }}">
                            @csrf
                            <div class="input-group">
                                <label class="input-label" for="message">Pesan permintaan</label>
                                <textarea id="message" name="message" rows="3" placeholder="Halo kak, sayurnya masih ada?" class="" style="min-width:280px;"></textarea>
                            </div>
                            <button class="button button-primary" type="submit">Request Item</button>
                        </form>
                        <a class="button button-secondary" href="https://wa.me/?text={{ urlencode('Halo, saya mau menanyakan status makanan yang Anda posting: '.$post->title) }}" target="_blank">Chat via WhatsApp</a>
                    @endif

                    @if($post->user_id === auth()->id() && $post->status === 'available')
                        <form method="POST" action="{{ route('posts.markTaken', $post) }}">
                            @csrf
                            <button class="button button-danger" type="submit">Tandai Sudah Diambil</button>
                        </form>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
