<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\OrderController;

/*
|--------------------------------------------------------------------------
| AUTH
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', fn(Request $request) => $request->user());
});

/*
|--------------------------------------------------------------------------
| CATEGORY (Admin Only)
|--------------------------------------------------------------------------
*/
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::post('/categories', [CategoryController::class, 'store']);
    Route::put('/categories/{id}', [CategoryController::class, 'update']);
    Route::delete('/categories/{id}', [CategoryController::class, 'destroy']);
});

/*
|--------------------------------------------------------------------------
| CATEGORY (Public)
|--------------------------------------------------------------------------
*/
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/categories/{id}', [CategoryController::class, 'show']);

/*
|--------------------------------------------------------------------------
| PRODUCT
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/products', [ProductController::class, 'index']);
    Route::get('/products/{id}', [ProductController::class, 'show']);
    Route::post('/products', [ProductController::class, 'store']);
    Route::put('/products/{id}', [ProductController::class, 'update']);
    Route::delete('/products/{id}', [ProductController::class, 'destroy']);
});

/*
|--------------------------------------------------------------------------
| CART
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::put('/cart/{id}', [CartController::class, 'update']);
    Route::delete('/cart/{id}', [CartController::class, 'destroy']);
    Route::delete('/cart/clear', [CartController::class, 'clearCart']);
});

/*
|--------------------------------------------------------------------------
| ORDER
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    // User
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders', [OrderController::class, 'index']); // chỉ đơn của người dùng
    Route::get('/orders/{id}', [OrderController::class, 'show']);
    Route::put('/orders/{id}/cancel', [OrderController::class, 'cancel']);

    // Admin
    Route::middleware('admin')->group(function () {
        Route::put('/orders/{id}/status', [OrderController::class, 'updateStatus']);
        Route::get('/admin/orders', [OrderController::class, 'getAllOrders']);
    });
});

/*
|--------------------------------------------------------------------------
| ORDER STATUS (for dropdown frontend)
|--------------------------------------------------------------------------
*/
Route::get('/order-statuses', function () {
    return response()->json([
        'pending' => 'Chờ xác nhận',
        'confirmed' => 'Đã xác nhận',
        'shipping' => 'Đang giao hàng',
        'completed' => 'Giao thành công',
        'canceled' => 'Đã huỷ',
    ]);
});
