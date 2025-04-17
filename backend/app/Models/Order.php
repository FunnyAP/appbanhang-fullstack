<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'user_id',
        'status',
        'total_price',
        'created_at',
        'updated_at',
    ];

    // Quan hệ với OrderDetail
    public function orderDetails()
    {
        return $this->hasMany(OrderDetail::class);
    }

    // Tính tổng giá tiền của đơn hàng
    public function getTotalPriceAttribute()
    {
        return $this->orderDetails->sum(function ($item) {
            return $item->price * $item->quantity;
        });
    }

    // (Tuỳ chọn) Quan hệ với User
    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
