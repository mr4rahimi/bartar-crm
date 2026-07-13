import { NextResponse, type NextRequest } from 'next/server';
import { validateSession } from '@/features/authentication/services/session.service';
import { SESSION_COOKIE_NAME } from '@/features/authentication/constants/session.constants';
import { apiError } from '@/shared/lib/api-response';

export async function GET(request: NextRequest) {
  const rawToken = request.cookies.get(SESSION_COOKIE_NAME)?.value;

  if (!rawToken) return apiError('احراز هویت نشده‌اید', 401);

  try {
    const result = await validateSession(rawToken);

    if (!result) return apiError('نشست شما منقضی شده است', 401);

    const response = NextResponse.json({ success: true, data: { user: result.user } });

    // Sliding Expiration — تمدید کوکی همراه با تمدید Session
    if (result.renewed && result.newExpiresAt) {
      response.cookies.set(SESSION_COOKIE_NAME, rawToken, {
        httpOnly: true,
        sameSite: 'lax',
        secure: process.env.NODE_ENV === 'production',
        path: '/',
        expires: result.newExpiresAt,
      });
    }

    return response;
  } catch (error) {
    console.error('[api/v1/auth/me]', error);
    return apiError('خطای داخلی سرور', 500);
  }
}
