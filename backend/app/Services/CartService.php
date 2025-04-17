<?php

namespace App\Services;

use App\Repositories\CartRepository;
use App\Models\Cart;

class CartService {
    protected $cartRepository;

    public function __construct(CartRepository $cartRepository) {
        $this->cartRepository = $cartRepository;
    }

    /**
     * 📦 Lấy danh sách giỏ hàng theo user hiện tại
     */
    public function getCartByUser() {
        return $this->cartRepository->getCartByUser();
    }

    /**
     * ➕ Thêm sản phẩm vào giỏ hàng (tăng số lượng nếu đã tồn tại)
     */
    public function addToCart(array $data) {
        $cart = Cart::where('user_id', auth()->id())
            ->where('product_id', $data['product_id'])
            ->first();

        if ($cart) {
            // ✅ Tăng số lượng nếu đã tồn tại
            $cart->quantity += $data['quantity'];
            $cart->save();
        } else {
            // ✅ Tạo mới nếu chưa có
            Cart::create([
                'user_id' => auth()->id(),
                'product_id' => $data['product_id'],
                'quantity' => $data['quantity'],
                'price' => $data['price'],
            ]);
        }
    }

    /**
     * 🔁 Cập nhật số lượng sản phẩm
     */
    public function updateCart($productId, $quantity) {
        $cart = Cart::where('user_id', auth()->id())
            ->where('product_id', $productId)
            ->first();
    
        if ($cart) {
            if ($quantity <= 0) {
                $cart->delete();
            } else {
                $cart->quantity = $quantity;
                $cart->save();
            }
        }
    
        return $this->getCartByUser();
    }
    

    /**
     * ❌ Xoá một sản phẩm khỏi giỏ
     */
    public function removeFromCart($productId) {
        Cart::where('user_id', auth()->id())
            ->where('product_id', $productId)
            ->delete();

        return $this->getCartByUser();
    }

    /**
     * 🧹 Xoá toàn bộ giỏ hàng của user
     */
    public function clearCart($userId) {
        $cartItems = Cart::where('user_id', $userId)->count();

        if ($cartItems == 0) {
            return false;
        }

        Cart::where('user_id', $userId)->delete();
        return true;
    }
}
