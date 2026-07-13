import { findUserByPhone } from '../repositories/user.repository';
import { createSession } from '../repositories/session.repository';
import { createActivityLog } from '../repositories/activity-log.repository';
import { verifyPassword } from '../utils/password.utils';
import { generateSessionToken, hashToken } from '../utils/token.utils';
import { SESSION_DURATION_DAYS } from '../constants/session.constants';
import type { LoginInput } from '../validators/login.schema';

export class InvalidCredentialsError extends Error {
  constructor() {
    super('شماره موبایل یا رمز عبور اشتباه است');
    this.name = 'InvalidCredentialsError';
  }
}

export class InactiveUserError extends Error {
  constructor() {
    super('حساب کاربری غیرفعال است');
    this.name = 'InactiveUserError';
  }
}

type LoginContext = {
  userAgent?: string | null;
  ip?: string | null;
};

export async function loginService(input: LoginInput, context: LoginContext = {}) {
  const user = await findUserByPhone(input.phone);

  if (!user) {
    throw new InvalidCredentialsError();
  }

  if (!user.isActive) {
    throw new InactiveUserError();
  }

  const isPasswordValid = await verifyPassword(input.password, user.passwordHash);

  if (!isPasswordValid) {
    throw new InvalidCredentialsError();
  }

  const rawToken = generateSessionToken();
  const tokenHash = hashToken(rawToken);
  const expiresAt = new Date(Date.now() + SESSION_DURATION_DAYS * 24 * 60 * 60 * 1000);

  await createSession({
    userId: user.id,
    tokenHash,
    expiresAt,
    userAgent: context.userAgent ?? null,
    ip: context.ip ?? null,
  });

  // طبق docs/10-development-rules.md — Login باید Log شود
  await createActivityLog({
    userId: user.id,
    action: 'LOGIN',
    entityType: 'User',
    entityId: user.id,
    ip: context.ip ?? null,
    device: context.userAgent ?? null,
  });

  const permissions = user.roles.flatMap((userRole) =>
    userRole.role.permissions.map((rolePermission) => rolePermission.permission.code),
  );

  return {
    rawToken,
    expiresAt,
    user: {
      id: user.id,
      name: user.name,
      phone: user.phone,
      email: user.email,
      permissions,
    },
  };
}
