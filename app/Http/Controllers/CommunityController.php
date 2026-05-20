<?php

namespace App\Http\Controllers;

use App\Models\Post;
use App\Models\User;

class CommunityController extends Controller
{
    public function index()
    {
        $members = User::query()
            ->latest()
            ->limit(20)
            ->get();

        $recentPosts = Post::query()
            ->latest()
            ->limit(10)
            ->get();

        $totalMembers = User::count();
        $totalPosts = Post::count();
        $availablePosts = Post::where('status', 'available')->count();

        return view('community.index', compact(
            'members',
            'recentPosts',
            'totalMembers',
            'totalPosts',
            'availablePosts'
        ));
    }
}