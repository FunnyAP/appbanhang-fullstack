<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CategoryService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CategoryController extends Controller {
    protected $categoryService;

    public function __construct(CategoryService $categoryService) {
        $this->categoryService = $categoryService;
    }

    // 📌 Lấy danh sách danh mục (User & Admin đều có thể xem)
    public function index() {
        return response()->json($this->categoryService->getAllCategories(), 200);
    }

    // 📌 Lấy chi tiết danh mục (User & Admin đều có thể xem)
    public function show($id) {
        return response()->json($this->categoryService->getCategoryById($id), 200);
    }

    // 📌 Chỉ Admin mới có thể tạo danh mục
    public function store(Request $request)
    {
        // ✅ Kiểm tra nếu user không phải admin, từ chối truy cập
        if (Auth::user()->role !== 'Admin') {
            return response()->json(['message' => 'loi ket noi'], 403);
        }

        // ✅ Validate dữ liệu đầu vào
        $validated = $request->validate([
            'name' => 'required|string|unique:categories',
            'slug' => 'required|string|unique:categories',
            'image' => 'nullable|string',
            'order' => 'integer',
            'status' => 'boolean',
        ]);

        // ✅ Tạo danh mục
        $category = $this->categoryService->createCategory($validated);

        return response()->json([
            'message' => 'Category created successfully',
            'category' => $category
        ], 201);
    }

    public function destroy($id)
    {
        // ✅ Kiểm tra nếu user không phải admin, từ chối truy cập
        if (auth()->user()->role !== 'Admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
    
        $category = $this->categoryService->getCategoryById($id);
        if (!$category) {
            return response()->json(['message' => 'Category not found'], 404);
        }
    
        $this->categoryService->deleteCategory($id);
    
        return response()->json(['message' => 'Category deleted successfully']);
    }
     
    public function update(Request $request, $id)
    {
        // ✅ Kiểm tra nếu user không phải admin, từ chối truy cập
        if (auth()->user()->role !== 'Admin') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }
    
        $request->validate([
            'name' => 'required|string|unique:categories,name,'.$id,
            'slug' => 'required|string|unique:categories,slug,'.$id,
            'image' => 'nullable|string',
            'order' => 'integer',
            'status' => 'boolean',
        ]);
    
        $category = $this->categoryService->updateCategory($id, $request->all());
    
        if (!$category) {
            return response()->json(['message' => 'Category not found'], 404);
        }
    
        return response()->json([
            'message' => 'Category updated successfully',
            'category' => $category
        ]);
    }
     
}
