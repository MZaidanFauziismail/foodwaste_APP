@extends('layouts.app')

@section('title', 'Chat')

@section('content')
<section class="flex min-h-[100dvh] flex-col bg-white">
    <div class="shrink-0 px-4 pt-4">
        <div class="mb-4 rounded-[28px] bg-white p-4 shadow-xl shadow-purple-100/70">
            <div class="flex items-center gap-3">
                <a
                    href="{{ route('posts.show', $post) }}"
                    class="flex h-10 w-10 items-center justify-center rounded-full bg-purple-100 text-lg font-extrabold text-purple-800"
                >@extends('layouts.app')

@section('title', 'Chat')

@section('content')
<section class="flex h-full flex-col bg-white">
    <div class="shrink-0 px-4 pt-4">
        <div class="mb-4 rounded-[28px] bg-white p-4 shadow-xl shadow-purple-100/70">
            <div class="flex items-center gap-3">
                <a
                    href="{{ route('posts.show', $post) }}"
                    class="flex h-10 w-10 items-center justify-center rounded-full bg-purple-100 text-lg font-extrabold text-purple-800"
                >
                    ←
                </a>

                <div class="flex h-12 w-12 items-center justify-center rounded-full bg-emerald-100 text-sm font-extrabold text-emerald-700">
                    {{ strtoupper(substr($user->name, 0, 1)) }}
                </div>

                <div class="min-w-0">
                    <h1 class="truncate text-base font-extrabold leading-tight text-slate-950">
                        {{ $user->name }}
                    </h1>

                    <p class="text-xs font-medium text-slate-500">
                        Chat tentang makanan
                    </p>
                </div>
            </div>
        </div>

        <div class="mb-5 rounded-[22px] border border-purple-100 bg-purple-50/80 p-3">
            <div class="flex items-center gap-3">
                @if($post->photo_path)
                    <img
                        src="{{ asset('storage/' . $post->photo_path) }}"
                        alt="{{ $post->title }}"
                        class="h-14 w-14 rounded-2xl object-cover"
                    >
                @else
                    <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-white text-2xl">
                        🍱
                    </div>
                @endif

                <div class="min-w-0">
                    <h2 class="truncate text-sm font-extrabold text-purple-800">
                        {{ $post->title }}
                    </h2>

                    <p class="mt-1 truncate text-xs text-slate-600">
                        {{ $post->label }} · {{ $post->location_text }}
                    </p>
                </div>
            </div>
        </div>

        <div class="mb-4 text-center">
            <span class="rounded-full bg-slate-100 px-3 py-1 text-[11px] font-semibold text-slate-400">
                Today
            </span>
        </div>
    </div>

    <div id="chat-messages" class="flex-1 space-y-4 overflow-y-auto px-5 pb-4">
        @forelse($messages as $message)
            @php
                $isMine = $message->sender_id === auth()->id();
            @endphp

            <div class="flex {{ $isMine ? 'justify-end' : 'justify-start' }}">
                <div class="max-w-[82%]">
                    <div
                        class="rounded-[20px] px-4 py-3 text-sm leading-6
                        {{ $isMine
                            ? 'rounded-br-md bg-purple-600 text-white shadow-lg shadow-purple-200/70'
                            : 'rounded-bl-md bg-slate-100 text-slate-800'
                        }}"
                    >
                        <p class="whitespace-pre-wrap break-words">
                            {{ $message->body }}
                        </p>
                    </div>

                    <p class="mt-1 text-[10px] text-slate-400 {{ $isMine ? 'text-right' : 'text-left' }}">
                        {{ $message->created_at->format('H:i') }}
                    </p>
                </div>
            </div>
        @empty
            <div class="flex min-h-[300px] items-center justify-center text-center">
                <div>
                    <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-purple-100 text-2xl">
                        💬
                    </div>

                    <h2 class="mt-4 text-xl font-extrabold text-slate-950">
                        Belum ada pesan
                    </h2>

                    <p class="mt-2 text-sm leading-6 text-slate-600">
                        Mulai chat untuk menanyakan ketersediaan makanan.
                    </p>
                </div>
            </div>
        @endforelse
    </div>

    <form
        method="POST"
        action="{{ route('chats.store', [$post, $user]) }}"
        class="shrink-0 border-t border-purple-100 bg-white px-4 py-3"
    >
        @csrf

        <div class="flex items-end gap-2 rounded-[28px] bg-white p-2 shadow-2xl shadow-purple-200/80">
            <textarea
                name="body"
                rows="1"
                required
                placeholder="Tulis pesan..."
                class="max-h-32 min-h-11 flex-1 resize-none rounded-full border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >{{ old('body') }}</textarea>

            <button
                type="submit"
                class="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-purple-600 text-lg font-extrabold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
            >
                →
            </button>
        </div>
    </form>
</section>

<script>
    window.addEventListener('load', () => {
        const chatMessages = document.getElementById('chat-messages');

        if (chatMessages) {
            chatMessages.scrollTop = chatMessages.scrollHeight;
        }
    });
</script>
@endsection
                    ←
                </a>

                <div class="flex h-12 w-12 items-center justify-center rounded-full bg-emerald-100 text-sm font-extrabold text-emerald-700">
                    {{ strtoupper(substr($user->name, 0, 1)) }}
                </div>

                <div class="min-w-0">
                    <h1 class="truncate text-base font-extrabold leading-tight text-slate-950">
                        {{ $user->name }}
                    </h1>

                    <p class="text-xs font-medium text-slate-500">
                        Chat tentang makanan
                    </p>
                </div>
            </div>
        </div>

        <div class="mb-5 rounded-[22px] border border-purple-100 bg-purple-50/80 p-3">
            <div class="flex items-center gap-3">
                @if($post->photo_path)
                    <img
                        src="{{ asset('storage/' . $post->photo_path) }}"
                        alt="{{ $post->title }}"
                        class="h-14 w-14 rounded-2xl object-cover"
                    >
                @else
                    <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-white text-2xl">
                        🍱
                    </div>
                @endif

                <div class="min-w-0">
                    <h2 class="truncate text-sm font-extrabold text-purple-800">
                        {{ $post->title }}
                    </h2>

                    <p class="mt-1 truncate text-xs text-slate-600">
                        {{ $post->label }} · {{ $post->location_text }}
                    </p>
                </div>
            </div>
        </div>

        <div class="mb-4 text-center">
            <span class="rounded-full bg-slate-100 px-3 py-1 text-[11px] font-semibold text-slate-400">
                Today
            </span>
        </div>
    </div>

    <div class="flex-1 space-y-4 overflow-y-auto px-5 pb-4">
        @forelse($messages as $message)
            @php
                $isMine = $message->sender_id === auth()->id();
            @endphp

            <div class="flex {{ $isMine ? 'justify-end' : 'justify-start' }}">
                <div class="max-w-[82%]">
                    <div
                        class="rounded-[20px] px-4 py-3 text-sm leading-6
                        {{ $isMine
                            ? 'rounded-br-md bg-purple-600 text-white shadow-lg shadow-purple-200/70'
                            : 'rounded-bl-md bg-slate-100 text-slate-800'
                        }}"
                    >
                        <p class="whitespace-pre-wrap break-words">
                            {{ $message->body }}
                        </p>
                    </div>

                    <p class="mt-1 text-[10px] text-slate-400 {{ $isMine ? 'text-right' : 'text-left' }}">
                        {{ $message->created_at->format('H:i') }}
                    </p>
                </div>
            </div>
        @empty
            <div class="flex min-h-[300px] items-center justify-center text-center">
                <div>
                    <div class="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-purple-100 text-2xl">
                        💬
                    </div>

                    <h2 class="mt-4 text-xl font-extrabold text-slate-950">
                        Belum ada pesan
                    </h2>

                    <p class="mt-2 text-sm leading-6 text-slate-600">
                        Mulai chat untuk menanyakan ketersediaan makanan.
                    </p>
                </div>
            </div>
        @endforelse
    </div>

    <form
        method="POST"
        action="{{ route('chats.store', [$post, $user]) }}"
        class="shrink-0 border-t border-purple-100 bg-white px-4 py-3"
    >
        @csrf

        <div class="flex items-end gap-2 rounded-[28px] bg-white p-2 shadow-2xl shadow-purple-200/80">
            <textarea
                name="body"
                rows="1"
                required
                placeholder="Tulis pesan..."
                class="max-h-32 min-h-11 flex-1 resize-none rounded-full border border-slate-200 bg-slate-50 px-4 py-3 text-sm text-slate-900 outline-none placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >{{ old('body') }}</textarea>

            <button
                type="submit"
                class="flex h-11 w-11 shrink-0 items-center justify-center rounded-full bg-purple-600 text-lg font-extrabold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
            >
                →
            </button>
        </div>
    </form>
</section>

<script>
    window.addEventListener('load', () => {
        window.scrollTo(0, document.body.scrollHeight);
    });
</script>
@endsection