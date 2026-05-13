<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ProfileController extends Controller
{
    public function index(Request $request)
    {
        return view('profile.index', ['user' => $request->user()]);
    }

    public function updateSettings(Request $request)
    {
        $data = $request->validate([
            'radius_km' => 'required|integer|min:1|max:50',
            'notification_keyword' => 'nullable|string|max:100',
        ]);

        $request->user()->update($data);

        return back()->with('success', 'Pengaturan radius dan notifikasi berhasil disimpan.');
    }

    public function updateTheme(Request $request)
    {
        $data = $request->validate([
            'theme' => 'required|in:light,dark',
        ]);

        $request->user()->update(['theme_mode' => $data['theme']]);

        return response()->json(['status' => 'ok']);
    }

    public function history(Request $request)
    {
        $user = $request->user();
        $shared = $user->posts()->orderByDesc('created_at')->get();
        $requests = $user->requests()->with('post')->orderByDesc('created_at')->get();

        return view('profile.history', compact('shared', 'requests'));
    }
}
