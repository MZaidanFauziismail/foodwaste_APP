<?php

use App\Http\Controllers\Api\AuthApiController;
use App\Http\Controllers\Api\PostApiController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthApiController::class, 'register']);
Route::post('/login', [AuthApiController::class, 'login']);
Route::get('/me', [AuthApiController::class, 'me']);
Route::post('/logout', [AuthApiController::class, 'logout']);

Route::get('/posts', [PostApiController::class, 'index']);
Route::post('/posts', [PostApiController::class, 'store']);
Route::post('/posts/{post}/request', [PostApiController::class, 'requestPost']);