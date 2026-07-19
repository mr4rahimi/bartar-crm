import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { SESSION_COOKIE_NAME } from '@/features/authentication/constants/session.constants';

// نکته: Middleware روی Edge Runtime اجرا می‌شود و Prisma در دسترس نیست.
// اینجا فقط «وجود» کوکی چک می‌شود؛ اعتبارسنجی واقعی Session در
// getCurrentUser و Route Handlerها (Server Runtime) انجام می‌شود.
// مسیرهای عمومی (/, /prices, /auth/*) اصلاً وارد matcher نمی‌شوند.
export function middleware(request: NextRequest) {
  const hasSessionCookie = request.cookies.has(SESSION_COOKIE_NAME);

  if (!hasSessionCookie) {
    const loginUrl = new URL('/auth/login', request.url);
    loginUrl.searchParams.set('redirect', request.nextUrl.pathname);
    return NextResponse.redirect(loginUrl);
  }

  return NextResponse.next();
}

// فقط مسیرهای پشت لاگین — بقیه (لندینگ و صفحه عمومی قیمت‌ها) آزادند
export const config = {
  matcher: [
    '/dashboard/:path*',
    '/part-requests/:path*',
    '/purchases/:path*',
    '/pricing/:path*',
    '/catalog/:path*',
    '/repairs/:path*',
    '/users/:path*',
    '/roles/:path*',
    '/settings/:path*',
    '/about/:path*',
  ],
};
