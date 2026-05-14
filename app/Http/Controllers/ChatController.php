<?php

namespace App\Http\Controllers;

use App\Models\Message;
use App\Models\Post;
use App\Models\User;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    public function show(Post $post, User $user)
    {
        $currentUser = auth()->user();

        $this->authorizeChat($post, $user);

        $messages = Message::query()
            ->where('post_id', $post->id)
            ->where(function ($query) use ($currentUser, $user) {
                $query->where(function ($q) use ($currentUser, $user) {
                    $q->where('sender_id', $currentUser->id)
                        ->where('receiver_id', $user->id);
                })->orWhere(function ($q) use ($currentUser, $user) {
                    $q->where('sender_id', $user->id)
                        ->where('receiver_id', $currentUser->id);
                });
            })
            ->oldest()
            ->get();

        Message::query()
            ->where('post_id', $post->id)
            ->where('sender_id', $user->id)
            ->where('receiver_id', $currentUser->id)
            ->whereNull('read_at')
            ->update([
                'read_at' => now(),
            ]);

        return view('chats.show', compact('post', 'user', 'messages'));
    }

    public function store(Request $request, Post $post, User $user)
    {
        $currentUser = auth()->user();

        $this->authorizeChat($post, $user);

        $validated = $request->validate([
            'body' => ['required', 'string', 'max:1000'],
        ]);

        Message::create([
            'post_id' => $post->id,
            'sender_id' => $currentUser->id,
            'receiver_id' => $user->id,
            'body' => $validated['body'],
        ]);

        return redirect()
            ->route('chats.show', [$post, $user]);
    }

    private function authorizeChat(Post $post, User $user): void
    {
        $currentUser = auth()->user();

        $isPostOwner = $post->user_id === $currentUser->id;
        $isChattingWithPostOwner = $post->user_id === $user->id;

        abort_if($currentUser->id === $user->id, 403);

        abort_unless($isPostOwner || $isChattingWithPostOwner, 403);
    }
}