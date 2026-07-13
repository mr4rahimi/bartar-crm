import type { NextRequest } from 'next/server';
import { SESSION_COOKIE_NAME } from '../constants/session.constants';
import { validateSession } from './session.service';
import { UnauthenticatedError, ForbiddenError } from '@/shared/lib/errors';
import type { AuthenticatedUser } from '../types/session.types';

/** Authenticate — از کوکی Session کاربر را استخراج و اعتبارسنجی می‌کند */
export async function authenticateRequest(request: NextRequest): Promise<AuthenticatedUser> {
  const rawToken = request.cookies.get(SESSION_COOKIE_NAME)?.value;
  if (!rawToken) throw new UnauthenticatedError();

  const result = await validateSession(rawToken);
  if (!result) throw new UnauthenticatedError();

  return result.user;
}

/** Authorize — همیشه Permission بررسی می‌شود، نه Role (docs/06-user-roles.md) */
export function requirePermission(user: AuthenticatedUser, permissionCode: string): void {
  if (!user.permissions.includes(permissionCode)) {
    throw new ForbiddenError();
  }
}
