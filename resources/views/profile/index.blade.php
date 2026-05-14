@extends('layouts.app')

@section('title', 'Profil & Pengaturan')

@section('content')
<section class="space-y-5">
    <div class="relative overflow-hidden rounded-[32px] border border-purple-100 bg-white p-6 shadow-2xl shadow-purple-200/60">
        <div class="absolute -right-16 -top-16 h-44 w-44 rounded-full bg-purple-300/40"></div>
        <div class="absolute -bottom-20 -left-20 h-48 w-48 rounded-full bg-emerald-200/40"></div>

        <div class="relative">
            <p class="mb-4 inline-flex rounded-full bg-purple-100 px-3 py-2 text-xs font-bold text-purple-800">
                Profil
            </p>

            <h1 class="text-3xl font-extrabold leading-tight tracking-tight text-slate-950">
                Profil & Pengaturan
            </h1>

            <p class="mt-3 text-sm leading-6 text-slate-600">
                Atur radius pencarian, keyword notifikasi, dan preferensi tampilan aplikasi.
            </p>
        </div>
    </div>

    <form method="POST" action="{{ route('profile.update') }}" class="space-y-5">
        @csrf
        @method('PUT')

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label class="mb-2 block text-sm font-bold text-slate-700">
                Nama
            </label>

            <input
                type="text"
                value="{{ auth()->user()->name }}"
                disabled
                class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-500 outline-none"
            >
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label class="mb-2 block text-sm font-bold text-slate-700">
                Email
            </label>

            <input
                type="email"
                value="{{ auth()->user()->email }}"
                disabled
                class="w-full rounded-2xl border border-slate-200 bg-slate-50 px-4 py-4 text-sm font-semibold text-slate-500 outline-none"
            >
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="radius_km" class="mb-2 block text-sm font-bold text-slate-700">
                Radius Pencarian
            </label>

            <div class="relative">
                <input
                    id="radius_km"
                    name="radius_km"
                    type="number"
                    min="1"
                    max="50"
                    value="{{ old('radius_km', auth()->user()->radius_km) }}"
                    required
                    class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 pr-12 text-sm font-semibold text-slate-900 outline-none transition focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
                >

                <span class="absolute right-4 top-1/2 -translate-y-1/2 text-sm font-bold text-slate-400">
                    km
                </span>
            </div>

            <p class="mt-2 text-xs leading-5 text-slate-500">
                Gunakan radius 1 sampai 50 km untuk mengatur jangkauan feed makanan.
            </p>
        </div>

        <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
            <label for="notification_keyword" class="mb-2 block text-sm font-bold text-slate-700">
                Keyword Notifikasi
            </label>

            <input
                id="notification_keyword"
                name="notification_keyword"
                type="text"
                value="{{ old('notification_keyword', auth()->user()->notification_keyword) }}"
                placeholder="Contoh: Roti"
                class="w-full rounded-2xl border border-purple-100 bg-purple-50/40 px-4 py-4 text-sm text-slate-900 outline-none transition placeholder:text-slate-400 focus:border-purple-400 focus:bg-white focus:ring-4 focus:ring-purple-100"
            >

            <p class="mt-2 text-xs leading-5 text-slate-500">
                Kamu akan mendapat alert jika ada postingan baru yang mengandung kata ini.
            </p>
        </div>

        <button
            type="submit"
            class="w-full rounded-full bg-purple-600 px-6 py-4 text-sm font-bold text-white shadow-lg shadow-purple-300/60 transition hover:bg-purple-700"
        >
            Simpan Pengaturan
        </button>
    </form>

    <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
        <div class="flex items-start justify-between gap-4">
            <div>
                <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
                    Tema UI
                </p>

                <h2 class="mt-2 text-xl font-extrabold text-slate-950">
                    Mode Tampilan
                </h2>

                <p class="mt-2 text-sm leading-6 text-slate-600">
                    Pilih cara tampilan aplikasi ketika digunakan.
                </p>
            </div>

            <span
                id="theme-label"
                class="rounded-full bg-purple-100 px-3 py-1.5 text-xs font-bold text-purple-800"
            >
                {{ auth()->user()->theme_mode ?? 'light' }}
            </span>
        </div>

        <button
            id="toggle-theme"
            type="button"
            class="mt-5 w-full rounded-full border border-purple-300 bg-white px-6 py-4 text-sm font-bold text-purple-800 transition hover:bg-purple-50"
        >
            Ganti Mode
        </button>
    </div>

    <div class="rounded-[28px] border border-purple-100 bg-white p-5 shadow-xl shadow-purple-100/70">
        <p class="text-xs font-bold uppercase tracking-wide text-slate-400">
            Ringkasan Profil
        </p>

        <h2 class="mt-2 text-xl font-extrabold text-slate-950">
            Preferensi Kamu
        </h2>

        <div class="mt-5 grid grid-cols-1 gap-3">
            <div class="rounded-2xl bg-purple-50/70 p-4">
                <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                    Radius saat ini
                </p>

                <p class="mt-1 text-lg font-extrabold text-slate-950">
                    {{ auth()->user()->radius_km }} km
                </p>
            </div>

            <div class="rounded-2xl bg-purple-50/70 p-4">
                <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                    Keyword alert
                </p>

                <p class="mt-1 text-lg font-extrabold text-slate-950">
                    {{ auth()->user()->notification_keyword ?: 'Tidak ada' }}
                </p>
            </div>

            <div class="rounded-2xl bg-purple-50/70 p-4">
                <p class="text-xs font-bold uppercase tracking-wide text-purple-700">
                    Mode tema
                </p>

                <p id="theme-summary" class="mt-1 text-lg font-extrabold text-slate-950">
                    {{ auth()->user()->theme_mode ?? 'light' }}
                </p>
            </div>
        </div>
    </div>
</section>

<script>
    const toggleThemeButton = document.getElementById('toggle-theme');
    const themeLabel = document.getElementById('theme-label');
    const themeSummary = document.getElementById('theme-summary');

    const currentUserTheme = @json(auth()->user()->theme_mode ?? 'light');
    const savedTheme = localStorage.getItem('theme') || currentUserTheme;

    document.documentElement.dataset.theme = savedTheme;

    if (themeLabel) {
        themeLabel.textContent = savedTheme;
    }

    if (themeSummary) {
        themeSummary.textContent = savedTheme;
    }

    toggleThemeButton?.addEventListener('click', () => {
        const current = document.documentElement.dataset.theme || 'light';
        const next = current === 'dark' ? 'light' : 'dark';

        document.documentElement.dataset.theme = next;
        localStorage.setItem('theme', next);

        if (themeLabel) {
            themeLabel.textContent = next;
        }

        if (themeSummary) {
            themeSummary.textContent = next;
        }

        fetch(@json(route('profile.theme')), {
            method: 'POST',
            credentials: 'same-origin',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
            },
            body: JSON.stringify({
                theme: next,
            }),
        }).catch(() => {
            alert('Gagal menyimpan tema. Coba lagi.');
        });
    });
</script>
@endsection