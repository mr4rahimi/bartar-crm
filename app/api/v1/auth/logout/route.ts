import { NextResponse, type NextRequest } from 'next/server';
import { logoutService } from '@/features/authentication/services/session.service';
import { SESSION_COOKIE_NAME } from '@/features/authentication/constants/session.constants';
import { apiError } from '@/shared/lib/api-response';

export async function POST(request: NextRequest) {
  const rawToken = request.cookies.get(SESSION_COOKIE_NAME)?.value;

  try {
    if (rawToken) {
      await logoutService(rawToken, {
        userAgent: request.headers.get('user-agent'),
        ip: request.headers.get('x-forwarded-for'),
      });
    }

    const response = NextResponse.json({ success: true, data: null });
    response.cookies.delete(SESSION_COOKIE_NAME);
    return response;
  } catch (error) {
    console.error('[api/v1/auth/logout]', error);
    return apiError('خطای داخلی سرور', 500);
  }
}
