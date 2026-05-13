<?php

namespace App\Http\Controllers;

use App\Models\Post;
use Illuminate\Http\Request;

class FeedController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $sort = $request->get('sort', 'distance');
        $location = session('user_location');

        $posts = Post::with('owner')->where('status', 'available');

        if ($location) {
            $posts = $posts->selectRaw(
                'posts.*, (6371 * acos(cos(radians(?)) * cos(radians(latitude)) * cos(radians(longitude) - radians(?)) + sin(radians(?)) * sin(radians(latitude)))) as distance',
                [$location['latitude'], $location['longitude'], $location['latitude']]
            );

            if ($user->radius_km) {
                $posts = $posts->havingRaw('distance <= ?', [$user->radius_km]);
            }

            if ($sort === 'newest') {
                $posts = $posts->orderBy('created_at', 'desc');
            } else {
                $posts = $posts->orderBy('distance', 'asc');
            }
        } else {
            $posts = $posts->orderBy('created_at', 'desc');
        }

        $posts = $posts->get();

        $alerts = collect();
        if ($user->notification_keyword) {
            $keyword = strtolower($user->notification_keyword);
            $alerts = $posts->filter(function ($post) use ($keyword) {
                return str_contains(strtolower($post->title . ' ' . $post->description), $keyword);
            });
        }

        return view('feed', compact('posts', 'location', 'alerts', 'sort'));
    }
}
