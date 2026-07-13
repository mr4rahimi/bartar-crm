import { NextResponse, type NextRequest } from 'next/server';
import { loginSchema } from '@/features/authentication/validators/login.schema';
import {
  loginService,
  InvalidCredentialsError,
  InactiveUserError,
} from '@/features/authentication/services/login.service';
import { SESSION_COOKIE_NAME } from '@/features/authentication/constants/session.constants';
import { apiError } from '@/shared/lib/api-response';

// Route فقط: Validate → Call Service → Return Response (11-AI_INSTRUCTIONS.md)
export async function POST(request: NextRequest) {
  const body = await request.json().catch(() => null);
  const parsed = loginSchema.safeParse(body);

  if (!parsed.success) {
    return apiError(
      'اطلاعات ورودی معتبر نیست',
      400,
      parsed.error.issues.map((issue) => ({
        field: issue.path.join('.'),
        message: issue.message,
      })),
    );
  }

  try {
    const { rawToken, expiresAt, user } = await loginService(parsed.data, {
      userAgent: request.headers.get('user-agent'),
      ip: request.headers.get('x-forwarded-for'),
    });

    const response = NextResponse.json({ success: true, data: { user } });
    response.cookies.set(SESSION_COOKIE_NAME, rawToken, {
      httpOnly: true,
      sameSite: 'lax',
      secure: process.env.NODE_ENV === 'production',
      path: '/',
      expires: expiresAt,
    });

    return response;
  } catch (error) {
    if (error instanceof InvalidCredentialsError) return apiError(error.message, 401);
    if (error instanceof InactiveUserError) return apiError(error.message, 403);

    console.error('[api/v1/auth/login]', error);
    return apiError('خطای داخلی سرور', 500);
  }
}
