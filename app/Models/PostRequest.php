<?php

namespace App\Models;

use Database\Factories\PostRequestFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

#[Fillable(['post_id', 'user_id', 'message', 'status', 'rating', 'thank_you'])]
class PostRequest extends Model
{
    use HasFactory;

    public function post()
    {
        return $this->belongsTo(Post::class);
    }

    public function requester()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
