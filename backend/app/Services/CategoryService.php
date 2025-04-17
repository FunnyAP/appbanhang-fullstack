<?php

namespace App\Services;

use App\Interfaces\CategoryRepositoryInterface;
use App\Models\Category;


class CategoryService {
    protected $categoryRepository;

    public function __construct(CategoryRepositoryInterface $categoryRepository) {
        $this->categoryRepository = $categoryRepository;
    }

    public function getAllCategories() {
        return $this->categoryRepository->getAllCategories();
    }

    public function getCategoryById($id) {
        return $this->categoryRepository->getCategoryById($id);
    }

    public function createCategory(array $data) {
        return $this->categoryRepository->createCategory($data);
    }

    public function updateCategory($id, $data)
    {
        $category = Category::find($id);
        if (!$category) {
            return null;
        }
    
        $category->update($data);
        return $category;
    }
    

    public function deleteCategory($id)
    {
        $category = Category::find($id);
        if ($category) {
            $category->delete();
        }
    }
    
}
