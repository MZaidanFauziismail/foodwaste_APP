<?php

use App\Http\Controllers\Api\AuthApiController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthApiController::class, 'register']);
Route::post('/login', [AuthApiController::class, 'login']);
Route::get('/me', [AuthApiController::class, 'me']);
Route::post('/logout', [AuthApiController::class, 'logout']);