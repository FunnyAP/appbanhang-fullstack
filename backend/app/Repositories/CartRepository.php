<?php

namespace App\Repositories;

use App\Models\Cart;
use Illuminate\Support\Facades\Auth;

class CartRepository {
    public function getCartByUser() {
        return Cart::where('user_id', Auth::id())->with('product')->get();
    }

    public function addToCart($data) {
        return Cart::create([
            'user_id' => Auth::id(),
            'product_id' => $data['product_id'],
            'quantity' => $data['quantity'],
            'price' => $data['price'],
        ]);
    }

    public function updateCart($id, $quantity) {
        $cart = Cart::where('user_id', Auth::id())->where('id', $id)->first();
        if ($cart) {
            $cart->update(['quantity' => $quantity]);
        }
        return $cart;
    }

    public function removeFromCart($id) {
        return Cart::where('user_id', Auth::id())->where('id', $id)->delete();
    }

    public function clearCart() {
        return Cart::where('user_id', Auth::id())->delete();
    }
}
