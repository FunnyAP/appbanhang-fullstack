<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        if ($request->user() && $request->user()->role == 'Admin') {
            return $next($request);
        }

        return response()->json(['message' => 'Bạn không có quyền truy cập.'], 403);
    }
}
