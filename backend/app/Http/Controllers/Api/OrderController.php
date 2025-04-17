<?php 

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\OrderService;
use Illuminate\Http\Request;
use App\Models\Order;

class OrderController extends Controller
{
    protected $orderService;

    public function __construct(OrderService $orderService)
    {
        $this->orderService = $orderService;
    }

    // ✅ 1. API Tạo đơn hàng
    public function store(Request $request)
    {
        $userId = auth()->id(); // Lấy ID của user đăng nhập
        $result = $this->orderService->createOrder($userId);

        return response()->json($result, $result['success'] ? 201 : 400);
    }

    // ✅ 2. API Lấy danh sách đơn hàng của user (đã format và thêm tổng tiền)
    public function index()
    {
        $userId = auth()->id();
        $orders = $this->orderService->getOrdersByUser($userId);

        // Gắn tổng tiền và định dạng ngày
        $data = collect($orders)->map(function ($order) {
            return [
                'id' => $order->id,
                'status' => $order->status,
                'created_at' => \Carbon\Carbon::parse($order->created_at)->format('d/m/Y H:i'),
                'total_price' => $order->orderDetails->sum(fn($item) => $item->quantity * $item->price),
                'details' => $order->orderDetails,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // ✅ 3. API Lấy chi tiết một đơn hàng
    public function show($id)
    {
        $order = $this->orderService->getOrderById($id);
        if (!$order) {
            return response()->json(['message' => 'Không tìm thấy đơn hàng'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $order->id,
                'status' => $order->status,
                'created_at' => \Carbon\Carbon::parse($order->created_at)->format('d/m/Y H:i'),
                'total_price' => $order->orderDetails->sum(fn($item) => $item->quantity * $item->price),
                'details' => $order->orderDetails,
            ]
        ]);
    }

    // ✅ 4. API Hủy đơn hàng
    public function cancel($id)
    {
        $userId = auth()->id();
        $result = $this->orderService->cancelOrder($id, $userId);

        return response()->json($result, $result['success'] ? 200 : 403);
    }

    // ✅ 5. API Xác nhận đơn hàng (chỉ Admin)
    public function confirm($id)
    {
        $result = $this->orderService->confirmOrder($id);
        return response()->json($result, $result['success'] ? 200 : 403);
    }

    // ✅ 6. Lấy danh sách toàn bộ đơn hàng (cho Admin)
    public function getAllOrders()
    {
        $orders = Order::with('orderDetails.product', 'user')->orderByDesc('created_at')->get();

        $data = $orders->map(function ($order) {
            return [
                'id' => $order->id,
                'user_name' => $order->user->name ?? 'N/A',
                'status' => $order->status,
                'created_at' => $order->created_at->format('d/m/Y H:i'),
                'total_price' => $order->orderDetails->sum(fn($item) => $item->quantity * $item->price),
                'details' => $order->orderDetails
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // ✅ 7. Admin cập nhật trạng thái đơn hàng
public function updateStatus(Request $request, $id)
{
    // Chỉ cho admin mới được dùng
    if (auth()->user()->role !== 'Admin') {
        return response()->json(['message' => 'Unauthorized'], 403);
    }

    $request->validate([
        'status' => 'required|in:pending,confirmed,shipping,completed,canceled',
    ]);

    $order = Order::findOrFail($id);
    $order->status = $request->status;
    $order->save();

    return response()->json([
        'success' => true,
        'message' => '✅ Cập nhật trạng thái thành công!',
    ]);
}

}
