<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Category extends Model
{
    use HasApiTokens, HasFactory, Notifiable; // ✅ Đảm bảo HasApiTokens được dùng

    protected $fillable = [ // ✅ Thêm dòng này để cho phép gán dữ liệu hàng loạt
        'name',
        'slug',
        'image',
        'order',
        'status',
    ];
}
