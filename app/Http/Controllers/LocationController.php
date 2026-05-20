<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

class LocationController extends Controller
{
    public function index()
    {
        return view('location.index');
    }

    public function update(Request $request)
    {
        $validated = $request->validate([
            'latitude' => ['required', 'numeric', 'between:-90,90'],
            'longitude' => ['required', 'numeric', 'between:-180,180'],
            'accuracy' => ['nullable', 'numeric', 'min:0'],
        ]);

        $user = $request->user();

        $data = [];

        if (Schema::hasColumn('users', 'latitude')) {
            $data['latitude'] = $validated['latitude'];
        }

        if (Schema::hasColumn('users', 'longitude')) {
            $data['longitude'] = $validated['longitude'];
        }

        if (Schema::hasColumn('users', 'location_accuracy')) {
            $data['location_accuracy'] = $validated['accuracy'] ?? null;
        }

        if (Schema::hasColumn('users', 'location_updated_at')) {
            $data['location_updated_at'] = now();
        }

        $user->forceFill($data)->save();

        if ($request->expectsJson()) {
            return response()->json([
                'message' => 'Lokasi berhasil disimpan.',
                'latitude' => $user->latitude,
                'longitude' => $user->longitude,
                'accuracy' => $user->location_accuracy ?? null,
            ]);
        }

        return redirect()
            ->route('location.index')
            ->with('success', 'Lokasi berhasil disimpan.');
    }
}