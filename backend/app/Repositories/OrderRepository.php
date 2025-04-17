<?php

namespace App\Repositories;

use App\Models\Order;
use App\Models\OrderDetail;

class OrderRepository
{
    public function createOrder($userId, $totalPrice)
    {
        return Order::create([
            'user_id' => $userId,
            'total_price' => $totalPrice,
            'status' => 'pending', // Mặc định trạng thái đơn hàng là "pending"
        ]);
    }

    public function addOrderDetails($orderId, $cartItems)
    {
        foreach ($cartItems as $item) {
            OrderDetail::create([
                'order_id' => $orderId,
                'product_id' => $item['product_id'],
                'quantity' => $item['quantity'],
                'price' => $item['price'], // Giá mỗi sản phẩm
            ]);
        }
    }
    

    public function getOrdersByUser($userId)
    {
        return Order::where('user_id', $userId)
                    ->select('id', 'total_price', 'status', 'created_at')
                    ->orderBy('created_at', 'desc')
                    ->get();
    }
    
    

    public function getOrderById($orderId)
    {
        return Order::with('orderDetails.product')->find($orderId);
    }

    public function cancelOrder($orderId)
    {
        return Order::where('id', $orderId)->update(['status' => 'cancelled']);
    }

    public function confirmOrder($orderId)
    {
        return Order::where('id', $orderId)->update(['status' => 'confirmed']);
    }
}
