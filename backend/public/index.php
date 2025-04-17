<?php
use Illuminate\Contracts\Http\Kernel;
use Illuminate\Http\Request;

// Bật output buffering và xử lý header ngay từ đầu
ob_start();
header_remove();

// Xử lý timezone
date_default_timezone_set('Asia/Ho_Chi_Minh');

define('LARAVEL_START', microtime(true));

/*
|--------------------------------------------------------------------------
| Check Maintenance Mode
|--------------------------------------------------------------------------
*/
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

/*
|--------------------------------------------------------------------------
| Register The Auto Loader
|--------------------------------------------------------------------------
*/
require __DIR__.'/../vendor/autoload.php';

/*
|--------------------------------------------------------------------------
| Run The Application
|--------------------------------------------------------------------------
*/
$app = require_once __DIR__.'/../bootstrap/app.php';

// Xử lý CORS headers trước khi khởi tạo kernel
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization, X-Requested-With');
header('Access-Control-Allow-Credentials: true');

// Xử lý request
$kernel = $app->make(Kernel::class);

try {
    $response = $kernel->handle(
        $request = Request::capture()
    );
    
    // Đảm bảo clean output buffer trước khi send
    while (ob_get_level() > 0) ob_end_clean();
    
    $response->send();
} catch (\Throwable $e) {
    // Xử lý lỗi tập trung
    http_response_code(500);
    header('Content-Type: application/json');
    echo json_encode([
        'error' => 'Internal Server Error',
        'message' => $e->getMessage()
    ]);
    exit;
} finally {
    $kernel->terminate($request, $response ?? null);
}