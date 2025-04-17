<?php 

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CartService;
use Illuminate\Http\Request;

class CartController extends Controller {
    protected $cartService;

    public function __construct(CartService $cartService) {
        $this->cartService = $cartService;
    }

    public function index() {
        return response()->json([
            'items' => $this->cartService->getCartByUser()
        ]);
    }
  
    public function store(Request $request) {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'price' => 'required|numeric|min:0',
        ]);

        $this->cartService->addToCart($request->all());

        return response()->json([
            'items' => $this->cartService->getCartByUser()
        ]);
    }

    public function update(Request $request, $id) {
        $request->validate([
            'quantity' => 'required|integer|min:0' // ✅ Cho phép bằng 0 để xoá
        ]);
    
        $this->cartService->updateCart($id, $request->quantity);
    
        return response()->json([
            'items' => $this->cartService->getCartByUser()
        ]);
    }
    

    public function destroy($id) {
        $this->cartService->removeFromCart($id);

        return response()->json([
            'items' => $this->cartService->getCartByUser()
        ]);
    }

    public function clearCart() {
        $user = auth()->user();

        if (!$user) {
            return response()->json(['message' => 'Unauthorized'], 401);
        }

        $deleted = $this->cartService->clearCart($user->id);

        return response()->json([
            'message' => $deleted ? 'All items removed from cart' : 'Cart is already empty',
            'items' => $this->cartService->getCartByUser()
        ]);
    }
}
