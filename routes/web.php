<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\FeedController;
use App\Http\Controllers\LocationController;
use App\Http\Controllers\PostController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\RequestController;
use Illuminate\Support\Facades\Route;

Route::get('/', [AuthController::class, 'welcome'])->name('welcome');

Route::get('/register', [AuthController::class, 'showRegister'])->name('register');
Route::post('/register', [AuthController::class, 'register'])->name('register.submit');

Route::get('/login', [AuthController::class, 'showLogin'])->name('login');
Route::post('/login', [AuthController::class, 'login'])->name('login.submit');

Route::middleware('auth')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

    Route::post('/location', [LocationController::class, 'update'])->name('location.update');

    Route::get('/feed', [FeedController::class, 'index'])->name('feed');

    Route::get('/posts/create', [PostController::class, 'create'])->name('posts.create');
    Route::post('/posts', [PostController::class, 'store'])->name('posts.store');

    Route::post('/posts/{post}/mark-taken', [PostController::class, 'markTaken'])->name('posts.markTaken');
    Route::post('/posts/{post}/request', [RequestController::class, 'store'])->name('posts.request');

    Route::get('/posts/{post}', [PostController::class, 'show'])->name('posts.show');

    Route::get('/chats/posts/{post}/users/{user}', [ChatController::class, 'show'])
        ->name('chats.show');

    Route::post('/chats/posts/{post}/users/{user}', [ChatController::class, 'store'])
        ->name('chats.store');

    Route::get('/profile', [ProfileController::class, 'index'])->name('profile.index');
    Route::put('/profile', [ProfileController::class, 'updateSettings'])->name('profile.update');
    Route::post('/profile/theme', [ProfileController::class, 'updateTheme'])->name('profile.theme');

    Route::get('/history', [ProfileController::class, 'history'])->name('profile.history');
});