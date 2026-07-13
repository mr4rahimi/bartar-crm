import {
  findSessionByTokenHash,
  extendSessionExpiry,
  deleteSessionByTokenHash,
} from '../repositories/session.repository';
import { findUserById } from '../repositories/user.repository';
import { hashToken } from '../utils/token.utils';
import { SESSION_DURATION_DAYS, SESSION_RENEW_THRESHOLD_DAYS } from '../constants/session.constants';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import type { AuthenticatedUser } from '../types/session.types';

type ValidateSessionResult = {
  user: AuthenticatedUser;
  renewed: boolean;
  newExpiresAt: Date | null;
} | null;

/** Sliding Expiration: اگه کمتر از ۱۵ روز به انقضا مونده، ۳۰ روز دیگه تمدید می‌شه */
export async function validateSession(rawToken: string): Promise<ValidateSessionResult> {
  const tokenHash = hashToken(rawToken);
  const session = await findSessionByTokenHash(tokenHash);

  if (!session) return null;

  if (session.expiresAt < new Date()) {
    await deleteSessionByTokenHash(tokenHash);
    return null;
  }

  const user = await findUserById(session.userId);
  if (!user) return null;

  const permissions = user.roles.flatMap((userRole) =>
    userRole.role.permissions.map((rolePermission) => rolePermission.permission.code),
  );

  const renewThreshold = new Date(
    Date.now() + SESSION_RENEW_THRESHOLD_DAYS * 24 * 60 * 60 * 1000,
  );

  let renewed = false;
  let newExpiresAt: Date | null = null;

  if (session.expiresAt < renewThreshold) {
    newExpiresAt = new Date(Date.now() + SESSION_DURATION_DAYS * 24 * 60 * 60 * 1000);
    await extendSessionExpiry(session.id, newExpiresAt);
    renewed = true;
  }

  return {
    renewed,
    newExpiresAt,
    user: {
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      permissions,
    },
  };
}

type LogoutContext = {
  userAgent?: string | null;
  ip?: string | null;
};

export async function logoutService(rawToken: string, context: LogoutContext = {}) {
  const tokenHash = hashToken(rawToken);
  const session = await findSessionByTokenHash(tokenHash);

  if (!session) return;

  await deleteSessionByTokenHash(tokenHash);

  await logActivity({
    userId: session.userId,
    action: 'LOGOUT',
    entityType: 'User',
    entityId: session.userId,
    ip: context.ip ?? null,
    device: context.userAgent ?? null,
  });
}
