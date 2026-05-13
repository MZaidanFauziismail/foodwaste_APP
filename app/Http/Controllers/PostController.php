<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class PostController extends Controller
{
    public function create()
    {
        return view('posts.create');
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string|max:1000',
            'location_text' => 'required|string|max:255',
            'available_until' => 'required|date',
            'label' => 'required|in:Gratis,Harga Diskon',
            'photo' => 'required|image|max:4096',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
        ]);

        $data['photo_path'] = $request->file('photo')->store('photos', 'public');
        $data['status'] = 'available';
        $data['user_id'] = $request->user()->id;

        $request->user()->posts()->create($data);

        return redirect()->route('feed')->with('success', 'Postingan berhasil dibuat dan akan muncul di feed sekitar Anda.');
    }

    public function show(Post $post)
    {
        if ($post->status === 'completed' && $post->user_id !== auth()->id()) {
            abort(404);
        }

        return view('posts.show', compact('post'));
    }

    public function markTaken(Post $post)
    {
        if ($post->user_id !== auth()->id()) {
            abort(403);
        }

        $post->status = 'completed';
        $post->save();

        return redirect()->route('profile.history')->with('success', 'Postingan ditandai sudah diambil dan dihapus dari feed publik.');
    }
}
