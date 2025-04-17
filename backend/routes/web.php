<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Response;
use Illuminate\Support\Facades\File;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application.
|
*/

Route::get('/', function () {
    return view('welcome');
});

// ✅ Route hiển thị ảnh từ public/images có kèm CORS
Route::get('/image-proxy/{filename}', function ($filename) {
    $path = public_path('images/' . $filename);

    if (!File::exists($path)) {
        abort(404);
    }

    $file = File::get($path);
    $type = File::mimeType($path);

    return Response::make($file, 200)
        ->header("Content-Type", $type)
        ->header("Access-Control-Allow-Origin", "*");
});
