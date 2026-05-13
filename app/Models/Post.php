<?php

namespace App\Models;

use Database\Factories\PostFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['user_id', 'title', 'description', 'location_text', 'available_until', 'label', 'photo_path', 'latitude', 'longitude', 'status'])]
class Post extends Model
{
    use HasFactory;

    protected $casts = [
        'available_until' => 'datetime',
    ];

    public function owner()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function requests()
    {
        return $this->hasMany(PostRequest::class);
    }
}
