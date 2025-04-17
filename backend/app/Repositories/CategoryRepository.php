<?php

namespace App\Repositories;

use App\Interfaces\CategoryRepositoryInterface;
use App\Models\Category;

class CategoryRepository implements CategoryRepositoryInterface {

    public function getAllCategories() {
        return Category::all();
    }

    public function getCategoryById($id) {
        return Category::findOrFail($id);
    }

    public function createCategory(array $data)
{
    return Category::create([
        'name' => $data['name'],
        'slug' => $data['slug'],
        'image' => $data['image'] ?? null,
        'order' => $data['order'] ?? 0,
        'status' => $data['status'] ?? true
    ]);
}

    public function updateCategory($id, array $data) {
        $category = Category::findOrFail($id);
        $category->update($data);
        return $category;
    }

    public function deleteCategory($id) {
        $category = Category::findOrFail($id);
        $category->delete();
        return $category;
    }
}
