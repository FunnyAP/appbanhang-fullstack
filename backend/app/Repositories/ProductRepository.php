<?php

namespace App\Repositories;

use App\Models\Product;

class ProductRepository
{
    public function getAll()
    {
        return Product::all();
    }

    public function findById($id)
    {
        return Product::findOrFail($id);
    }

    public function create(array $data)
    {
        return Product::create($data);
    }

    public function update($id, array $data)
    {
        $product = Product::findOrFail($id);
        $product->update($data);
        return $product;
    }

    public function delete($id)
    {
        $product = Product::findOrFail($id);
        $product->delete();
    }

    public function searchByKeyword($keyword)
    {
        return Product::where('name', 'like', "%$keyword%")->get();
    }

    public function getAllWithCategory()
{
    return Product::with('category')->get();
}

public function findWithCategory($id)
{
    return Product::with('category')->find($id);
}

}
