<!DOCTYPE html>
<html lang="id" data-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title') - Food Waste App</title>
    <style>
        :root {
            --bg: #f9fafb;
            --surface: #ffffff;
            --text: #111827;
            --muted: #6b7280;
            --primary: #16a34a;
            --danger: #dc2626;
            --border: #d1d5db;
            --card: #ffffff;
        }
        [data-theme='dark'] {
            --bg: #0f172a;
            --surface: #12223b;
            --text: #f8fafc;
            --muted: #94a3b8;
            --primary: #22c55e;
            --danger: #fb7185;
            --border: #334155;
            --card: #1e293b;
        }
        * { box-sizing: border-box; }
        body {
            margin: 0;
            font-family: Inter, system-ui, sans-serif;
            background: var(--bg);
            color: var(--text);
        }
        a { color: inherit; text-decoration: none; }
        .page { max-width: 1120px; margin: 0 auto; padding: 1.25rem; }
        header { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 1rem; margin-bottom: 1.5rem; }
        .logo { font-weight: 800; letter-spacing: -.04em; font-size: 1.35rem; }
        .nav { display: flex; flex-wrap: wrap; gap: .75rem; }
        .button, .pill, .card button { display: inline-flex; align-items: center; justify-content: center; border: 1px solid transparent; padding: .8rem 1rem; border-radius: .75rem; cursor: pointer; transition: transform .12s ease, background .12s ease; }
        .button:hover, .pill:hover, .card button:hover { transform: translateY(-1px); }
        .button-primary { background: var(--primary); color: #fff; }
        .button-secondary { background: transparent; color: var(--text); border-color: var(--border); }
        .button-danger { background: var(--danger); color: #fff; }
        .pill { background: var(--surface); border-color: var(--border); color: var(--muted); }
        .card { background: var(--card); border: 1px solid var(--border); border-radius: 1rem; padding: 1rem; box-shadow: 0 10px 30px rgba(15,23,42,.08); }
        .grid { display: grid; gap: 1rem; }
        .grid-2 { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        .grid-3 { grid-template-columns: repeat(3, minmax(0, 1fr)); }
        input, textarea, select { width: 100%; border-radius: .75rem; border: 1px solid var(--border); background: var(--surface); color: var(--text); padding: .85rem 1rem; font: inherit; }
        input:focus, textarea:focus, select:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 4px rgba(34,197,94,.12); }
        .banner { padding: 1rem 1.25rem; border-radius: 1rem; background: rgba(34,197,94,.12); color: var(--text); border: 1px solid rgba(34,197,94,.25); margin-bottom: 1rem; }
        .flash { margin-bottom: 1rem; padding: 1rem 1.25rem; border-radius: 1rem; background: rgba(59,130,246,.12); color: var(--text); border: 1px solid rgba(59,130,246,.2); }
        .error { margin-bottom: 1rem; padding: 1rem 1.25rem; border-radius: 1rem; background: rgba(248,113,113,.12); color: var(--text); border: 1px solid rgba(248,113,113,.2); }
        .footer { margin-top: 2rem; text-align: center; color: var(--muted); }
        .hero { display: grid; gap: 1.5rem; }
        .hero h1 { margin: 0; font-size: clamp(2.5rem, 4vw, 4rem); line-height: 1; }
        .hero p { line-height: 1.8; max-width: 54rem; }
        .input-group { margin-bottom: 1rem; }
        .input-label { display: block; margin-bottom: .5rem; font-weight: 600; }
        .help-text { color: var(--muted); font-size: .95rem; margin-top: .35rem; }
    </style>
</head>
<body>
    <div class="page">
        <header>
            <div class="logo">Food Waste App</div>
            <div class="nav">
                @auth
                    <a class="button button-secondary" href="{{ route('feed') }}">Feed</a>
                    <a class="button button-secondary" href="{{ route('posts.create') }}">Bagikan Makanan</a>
                    <a class="button button-secondary" href="{{ route('profile.index') }}">Profil</a>
                    <a class="button button-secondary" href="{{ route('profile.history') }}">Riwayat</a>
                    <form method="POST" action="{{ route('logout') }}" style="display:inline;">
                        @csrf
                        <button class="button button-secondary" type="submit">Logout</button>
                    </form>
                @else
                    <a class="button button-primary" href="{{ route('register') }}">Sign Up</a>
                    <a class="button button-secondary" href="{{ route('login') }}">Log In</a>
                @endauth
                <button id="theme-toggle" class="button button-secondary" type="button">Mode Gelap / Terang</button>
            </div>
        </header>

        @if(session('success'))
            <div class="flash">{{ session('success') }}</div>
        @endif

        @if($errors->any())
            <div class="error">
                <ul style="margin:0; padding-left:1.25rem;">
                    @foreach($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif

        @yield('content')

        <footer class="footer">
            &copy; {{ date('Y') }} Food Waste App — Aplikasi berbagi makanan lokal.
        </footer>
    </div>

    <script>
        const themeButton = document.getElementById('theme-toggle');
        const userPreferred = localStorage.getItem('theme');
        const defaultTheme = userPreferred || '{{ auth()->check() ? auth()->user()->theme_mode : 'light' }}';
        document.documentElement.dataset.theme = defaultTheme;

        const themeRoute = @auth '{{ route('profile.theme') }}' @else null @endauth;

        const setTheme = (mode) => {
            document.documentElement.dataset.theme = mode;
            localStorage.setItem('theme', mode);

            if (!themeRoute) {
                return;
            }

            fetch(themeRoute, {
                method: 'POST',
                credentials: 'same-origin',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').content,
                },
                body: JSON.stringify({ theme: mode }),
            }).catch(() => {});
        };

        themeButton?.addEventListener('click', () => {
            const next = document.documentElement.dataset.theme === 'dark' ? 'light' : 'dark';
            setTheme(next);
        });

        if (!userPreferred) {
            document.documentElement.dataset.theme = defaultTheme;
        }
    </script>
</body>
</html>
