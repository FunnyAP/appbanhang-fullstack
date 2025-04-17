<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Auth;

class AuthController extends Controller
{
    // 📌 API Đăng ký
    public function register(Request $request)
    {
        // Kiểm tra dữ liệu nhập vào
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed', // Đảm bảo mật khẩu được xác nhận
            'phone' => 'required|string', // Nếu cần
        ]);
    
        // Tạo người dùng mới (tất cả sẽ có role là 'user')
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'phone' => $request->phone, // Nếu bạn muốn lưu số điện thoại
            'role' => 'user', // Mặc định role là 'user'
        ]);
    
        // Tạo token cho người dùng
        $token = $user->createToken('authToken')->plainTextToken;
    
        // Trả về kết quả dưới dạng JSON
        return response()->json([
            'message' => 'User registered successfully',
            'user' => $user,
            'token' => $token
        ], 201);
    }
    
    
    

    // 📌 API Đăng nhập
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|string|email',
            'password' => 'required|string|min:6',
        ]);

        $user = User::where('email', $request->email)->first(); // ✅ Kiểm tra user trong database

        if (!$user || !Hash::check($request->password, $user->password)) {
            // return response()->json(['message' => 'Invalid credentials'], 401);
            dd([
                'input_password' => $request->password,
                'hashed_password' => $user ? $user->password : 'No user found',
                'password_match' => $user ? Hash::check($request->password, $user->password) : false
            ]);
        }

        $token = $user->createToken('authToken')->plainTextToken; // ✅ Fix lỗi createToken()

        return response()->json(['user' => $user, 'token' => $token]);
    }

    // 📌 API Đăng xuất
    public function logout(Request $request)
    {
        // Xóa tất cả token của user hiện tại
        $request->user()->tokens()->delete();
    
        return response()->json(['message' => 'Logged out successfully']);
    }
}
