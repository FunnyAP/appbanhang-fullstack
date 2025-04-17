<?php

namespace App\Services;

use App\Repositories\ProductRepository;

class ProductService
{
    protected $repo;

    public function __construct(ProductRepository $repo)
    {
        $this->repo = $repo;
    }

    public function getAllProducts()
    {
        $products = $this->repo->getAllWithCategory();

        return $products->map(function ($product) {
            return [
                'id' => $product->id,
                'name' => htmlspecialchars($product->name, ENT_QUOTES, 'UTF-8'),
                'slug' => $product->slug,
                'description' => $product->description,
                'price' => $product->price,
                'stock' => $product->stock,
                'status' => $product->status,
                'category_id' => $product->category_id,
                'created_at' => $product->created_at,
                'updated_at' => $product->updated_at,
                'category' => $product->category,
                'image' => $product->image,
                'image_url' => is_string($product->image) && trim($product->image) !== ''? asset('images/' . trim($product->image)): null,

            ];
        });
    }

    public function getProductById($id)
    {
        $product = $this->repo->findWithCategory($id);

        if (!$product) {
            return null;
        }

        return [
            'id' => $product->id,
            'name' => $product->name,
            'slug' => $product->slug,
            'description' => $product->description,
            'price' => $product->price,
            'stock' => $product->stock,
            'status' => $product->status,
            'category_id' => $product->category_id,
            'created_at' => $product->created_at,
            'updated_at' => $product->updated_at,
            'category' => $product->category,
            'image' => $product->image,
            'image_url' => $product->image ? asset('images/' . trim($product->image)) : null,
        ];
    }

    public function createProduct($data)
    {
        return $this->repo->create($data);
    }

    public function updateProduct($id, $data)
    {
        return $this->repo->update($id, $data);
    }

    public function deleteProduct($id)
    {
        return $this->repo->delete($id);
    }
}
