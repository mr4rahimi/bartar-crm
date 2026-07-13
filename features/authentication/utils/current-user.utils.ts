import { cookies } from 'next/headers';
import { SESSION_COOKIE_NAME } from '../constants/session.constants';
import { validateSession } from '../services/session.service';
import type { AuthenticatedUser } from '../types/session.types';

/** فقط Server-Side (Server Components و Route Handlers) */
export async function getCurrentUser(): Promise<AuthenticatedUser | null> {
  const rawToken = cookies().get(SESSION_COOKIE_NAME)?.value;
  if (!rawToken) return null;

  const result = await validateSession(rawToken);
  return result?.user ?? null;
}
