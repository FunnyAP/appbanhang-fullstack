<?php 

namespace App\Services;

use App\Repositories\OrderRepository;
use App\Repositories\CartRepository;
use Illuminate\Support\Facades\DB;

class OrderService
{
    protected $orderRepository;
    protected $cartRepository;

    public function __construct(OrderRepository $orderRepository, CartRepository $cartRepository)
    {
        $this->orderRepository = $orderRepository;
        $this->cartRepository = $cartRepository;
    }

    public function createOrder($userId)
    {
        // ✅ Lấy giỏ hàng của user
        $cartItems = $this->cartRepository->getCartByUser($userId);
        if (count($cartItems) === 0) {
            return ['success' => false, 'message' => 'Giỏ hàng trống!'];
        }

        $totalPrice = array_sum(array_map(function ($item) {
            return $item['price'] * $item['quantity']; // 🔥 Sửa cú pháp thành `['key']`
        }, $cartItems->toArray()));
        

        DB::beginTransaction(); // Bắt đầu transaction

        try {
            // ✅ 1. Tạo đơn hàng trong bảng `orders`
            $order = $this->orderRepository->createOrder($userId, $totalPrice);

            // ✅ 2. Thêm sản phẩm vào bảng `order_details`
            $orderDetails = [];

            foreach ($cartItems as $item) {
                $orderDetails[] = [
                    'order_id' => $order->id,
                    'product_id' => $item['product_id'], // 🔥 Sử dụng `['key']` thay vì `->key`
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
            
            // ✅ Chèn nhiều bản ghi vào `order_details` cùng lúc
            DB::table('order_details')->insert($orderDetails);
            

            // ✅ 3. Xóa giỏ hàng sau khi đặt hàng thành công
            $this->cartRepository->clearCart($userId);

            DB::commit(); // Lưu thay đổi vào database
            return ['success' => true, 'message' => 'Đặt hàng thành công!', 'order' => $order];

        } catch (\Exception $e) {
            DB::rollBack(); // Hoàn tác nếu có lỗi
            return ['success' => false, 'message' => 'Lỗi đặt hàng: ' . $e->getMessage()];
        }
    }

    public function getOrdersByUser($userId)
    {
        return $this->orderRepository->getOrdersByUser($userId);
    }

    public function getOrderById($orderId)
    {
        return $this->orderRepository->getOrderById($orderId);
    }

    public function cancelOrder($orderId, $userId)
    {
        $order = $this->orderRepository->getOrderById($orderId);

        if (!$order || $order->user_id !== $userId) {
            return ['success' => false, 'message' => 'Không tìm thấy đơn hàng hoặc không có quyền hủy.'];
        }

        if ($order->status !== 'pending') {
            return ['success' => false, 'message' => 'Chỉ có thể hủy đơn hàng khi đang chờ xử lý.'];
        }

        $this->orderRepository->cancelOrder($orderId);
        return ['success' => true, 'message' => 'Đã hủy đơn hàng.'];
    }

    public function confirmOrder($orderId)
    {
        $order = $this->orderRepository->getOrderById($orderId);

        if (!$order) {
            return ['success' => false, 'message' => 'Không tìm thấy đơn hàng.'];
        }

        if ($order->status !== 'pending') {
            return ['success' => false, 'message' => 'Chỉ có thể xác nhận đơn hàng khi đang chờ xử lý.'];
        }

        $this->orderRepository->confirmOrder($orderId);
        return ['success' => true, 'message' => 'Đơn hàng đã được xác nhận.'];
    }
}
