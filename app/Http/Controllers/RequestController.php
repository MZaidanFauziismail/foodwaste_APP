<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\PostRequest;
use Illuminate\Http\Request;

class RequestController extends Controller
{
    public function store(Request $request, Post $post)
    {
        if ($post->status !== 'available') {
            return back()->withErrors(['message' => 'Maaf, item ini sudah tidak tersedia.']);
        }

        if ($post->user_id === $request->user()->id) {
            return back()->withErrors(['message' => 'Anda tidak dapat meminta item Anda sendiri.']);
        }

        $request->validate([
            'message' => 'nullable|string|max:500',
        ]);

        $existing = PostRequest::where('post_id', $post->id)
            ->where('user_id', $request->user()->id)
            ->first();

        if ($existing) {
            return back()->with('success', 'Anda sudah mengirim permintaan untuk item ini.');
        }

        PostRequest::create([
            'post_id' => $post->id,
            'user_id' => $request->user()->id,
            'message' => $request->message,
            'status' => 'pending',
        ]);

        return back()->with('success', 'Permintaan berhasil dikirim. Hubungi penjual untuk mengonfirmasi pengambilan.');
    }
}
