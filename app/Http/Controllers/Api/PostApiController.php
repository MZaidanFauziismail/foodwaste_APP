<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;

class PostApiController extends Controller
{
    public function index()
    {
        $posts = Post::query()
            ->latest()
            ->limit(50)
            ->get()
            ->map(fn ($post) => $this->transformPost($post));

        return response()->json([
            'posts' => $posts,
        ]);
    }

    public function store(Request $request)
    {
        $user = $this->userFromToken($request);

        if (! $user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        $validated = $request->validate([
            'title' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'location_text' => ['nullable', 'string', 'max:255'],
            'pickup_time' => ['nullable', 'string', 'max:255'],
            'latitude' => ['nullable'],
            'longitude' => ['nullable'],
            'type' => ['nullable', 'string', 'max:50'],
            'price' => ['nullable'],
            'image' => ['nullable', 'image', 'max:4096'],
            'photo' => ['nullable', 'image', 'max:4096'],
        ]);

        $post = new Post();
        $columns = Schema::getColumnListing($post->getTable());
        $data = [];

        $this->setIfColumnExists($data, $columns, 'user_id', $user->id);
        $this->setIfColumnExists($data, $columns, 'title', $validated['title']);
        $this->setIfColumnExists($data, $columns, 'description', $validated['description'] ?? null);
        $this->setIfColumnExists($data, $columns, 'location_text', $validated['location_text'] ?? null);
        $this->setIfColumnExists($data, $columns, 'pickup_time', $validated['pickup_time'] ?? null);
        $this->setIfColumnExists($data, $columns, 'latitude', $validated['latitude'] ?? null);
        $this->setIfColumnExists($data, $columns, 'longitude', $validated['longitude'] ?? null);
        $this->setIfColumnExists($data, $columns, 'type', $validated['type'] ?? 'free');
        $this->setIfColumnExists($data, $columns, 'price', $validated['price'] ?? 0);
        $this->setIfColumnExists($data, $columns, 'status', 'available');

        $file = $request->file('image') ?: $request->file('photo');

        if ($file) {
            $path = $file->store('posts', 'public');

            if (in_array('image_path', $columns)) {
                $data['image_path'] = $path;
            } elseif (in_array('image', $columns)) {
                $data['image'] = $path;
            } elseif (in_array('photo', $columns)) {
                $data['photo'] = $path;
            }
        }

        $created = Post::query()->create($data);

        return response()->json([
            'message' => 'Posting berhasil dibuat',
            'post' => $this->transformPost($created),
        ], 201);
    }

    public function requestPost(Request $request, Post $post)
    {
        $user = $this->userFromToken($request);

        if (! $user) {
            return response()->json([
                'message' => 'Unauthenticated',
            ], 401);
        }

        $columns = Schema::getColumnListing($post->getTable());

        if (in_array('status', $columns)) {
            $post->status = 'requested';
        }

        if (in_array('requester_id', $columns)) {
            $post->requester_id = $user->id;
        }

        $post->save();

        return response()->json([
            'message' => 'Request berhasil',
            'post' => $this->transformPost($post),
        ]);
    }

    private function transformPost(Post $post): array
    {
        $imagePath = $post->image_path
            ?? $post->image
            ?? $post->photo
            ?? null;

        $imageUrl = null;

        if ($imagePath) {
            if (str_starts_with($imagePath, 'http')) {
                $imageUrl = $imagePath;
            } else {
                $imageUrl = url(Storage::url($imagePath));
            }
        }

        return [
            'id' => $post->id,
            'title' => $post->title ?? '',
            'description' => $post->description ?? '',
            'location_text' => $post->location_text ?? '',
            'pickup_time' => $post->pickup_time ?? '',
            'latitude' => $post->latitude ?? null,
            'longitude' => $post->longitude ?? null,
            'type' => $post->type ?? 'free',
            'price' => $post->price ?? 0,
            'status' => $post->status ?? 'available',
            'image_url' => $imageUrl,
            'created_at' => optional($post->created_at)->toDateTimeString(),
        ];
    }

    private function userFromToken(Request $request): ?User
    {
        $plainToken = $request->bearerToken();

        if (! $plainToken) {
            return null;
        }

        return User::query()
            ->where('api_token', hash('sha256', $plainToken))
            ->first();
    }

    private function setIfColumnExists(array &$data, array $columns, string $key, mixed $value): void
    {
        if (in_array($key, $columns)) {
            $data[$key] = $value;
        }
    }
}