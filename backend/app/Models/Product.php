<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ProductService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use App\Models\Product;
use Illuminate\Support\Str;

class ProductController extends Controller
{
    protected $productService;

    public function __construct(ProductService $productService)
    {
        $this->productService = $productService;
    }

    public function index()
    {
        try {
            // Xử lý header trước khi trả về response
            header_remove();
            ob_start();
            
            $products = $this->productService->getAllProducts();
            return response()->json($products)
                ->setEncodingOptions(JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
                
        } catch (\Throwable $e) {
            Log::error("Lỗi lấy danh sách sản phẩm: " . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'error' => true,
                'message' => 'Lỗi server khi lấy danh sách sản phẩm.'
            ], 500);
        }
    }

    public function show($id)
    {
        try {
            header_remove();
            ob_start();
            
            $product = $this->productService->getProductById($id);
            return response()->json($product)
                ->setEncodingOptions(JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
                
        } catch (\Throwable $e) {
            Log::error("Lỗi khi lấy chi tiết sản phẩm: " . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'error' => true,
                'message' => 'Lỗi khi lấy sản phẩm'
            ], 500);
        }
    }

    public function store(Request $request)
    {
        // Kiểm tra và xử lý header
        header_remove();
        ob_start();

        if (!auth()->check() || auth()->user()->role !== 'Admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        // Validate dữ liệu với regex an toàn
        $validated = $request->validate([
            'name' => 'required|string|unique:products|regex:/^[a-zA-Z0-9\sÀ-ỹ\-_,.]+$/',
            'slug' => 'nullable|string|unique:products|regex:/^[a-z0-9\-]+$/',
            'description' => 'nullable|string',
            'price' => 'required|numeric|min:0',
            'stock' => 'required|integer|min:0',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'category_id' => 'required|exists:categories,id',
            'status' => 'boolean',
        ]);

        // Xử lý slug tự động nếu không nhập
        if (empty($validated['slug'])) {
            $validated['slug'] = Str::slug($validated['name']);
        }

        $data = $request->except('image');

        // Xử lý upload ảnh an toàn
        if ($request->hasFile('image') && $request->file('image')->isValid()) {
            $originalName = $request->file('image')->getClientOriginalName();
            $cleanedName = preg_replace('/[^\w\.\-]/', '', $originalName);
            $imageName = time() . '_' . $cleanedName;
            
            $request->file('image')->move(public_path('images'), $imageName);
            $data['image'] = $imageName;
        }

        try {
            $product = $this->productService->createProduct($data);
            return response()->json([
                'message' => 'Thêm sản phẩm thành công',
                'product' => $product
            ], 201)->setEncodingOptions(JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
            
        } catch (\Throwable $e) {
            Log::error("Lỗi khi tạo sản phẩm: " . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'message' => 'Lỗi khi tạo sản phẩm'
            ], 500);
        }
    }

    public function update(Request $request, $id)
    {
        header_remove();
        ob_start();

        if (!auth()->check() || auth()->user()->role !== 'Admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $product = Product::find($id);
        if (!$product) {
            return response()->json(['message' => 'Product not found'], 404);
        }

        $validated = $request->validate([
            'name' => 'sometimes|string|unique:products,name,' . $id,
            'slug' => 'sometimes|string|unique:products,slug,' . $id,
            'description' => 'nullable|string',
            'price' => 'numeric|min:0',
            'stock' => 'integer|min:0',
            'image' => 'nullable|image|mimes:jpg,jpeg,png|max:2048',
            'category_id' => 'exists:categories,id',
            'status' => 'boolean',
        ]);

        // Tự động cập nhật slug nếu name thay đổi
        if ($request->has('name') && !$request->has('slug')) {
            $validated['slug'] = Str::slug($request->name);
        }

        $data = $request->except('image');

        if ($request->hasFile('image') && $request->file('image')->isValid()) {
            // Xóa ảnh cũ nếu tồn tại
            if ($product->image && file_exists(public_path('images/' . $product->image))) {
                unlink(public_path('images/' . $product->image));
            }

            $originalName = $request->file('image')->getClientOriginalName();
            $cleanedName = preg_replace('/[^\w\.\-]/', '', $originalName);
            $imageName = time() . '_' . $cleanedName;
            
            $request->file('image')->move(public_path('images'), $imageName);
            $data['image'] = $imageName;
        }

        try {
            $product->update($data);
            return response()->json([
                'message' => 'Cập nhật sản phẩm thành công',
                'product' => $product
            ])->setEncodingOptions(JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
            
        } catch (\Throwable $e) {
            Log::error("Lỗi khi cập nhật sản phẩm: " . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'message' => 'Lỗi khi cập nhật sản phẩm'
            ], 500);
        }
    }

    public function destroy($id)
    {
        header_remove();
        ob_start();

        if (!auth()->check() || auth()->user()->role !== 'Admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        try {
            $product = Product::find($id);
            
            // Xóa ảnh đính kèm nếu có
            if ($product->image && file_exists(public_path('images/' . $product->image))) {
                unlink(public_path('images/' . $product->image));
            }

            $this->productService->deleteProduct($id);
            return response()->json([
                'message' => 'Xoá sản phẩm thành công'
            ])->setEncodingOptions(JSON_HEX_TAG | JSON_HEX_APOS | JSON_HEX_AMP | JSON_HEX_QUOT);
            
        } catch (\Throwable $e) {
            Log::error("Lỗi khi xoá sản phẩm: " . $e->getMessage(), [
                'trace' => $e->getTraceAsString()
            ]);
            return response()->json([
                'message' => 'Lỗi khi xoá sản phẩm'
            ], 500);
        }
    }
}