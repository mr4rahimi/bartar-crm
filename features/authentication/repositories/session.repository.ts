import { prisma } from '@/shared/lib/prisma';

type CreateSessionInput = {
  userId: string;
  tokenHash: string;
  expiresAt: Date;
  userAgent?: string | null;
  ip?: string | null;
};

export async function createSession(input: CreateSessionInput) {
  return prisma.session.create({ data: input });
}

export async function findSessionByTokenHash(tokenHash: string) {
  return prisma.session.findUnique({ where: { tokenHash } });
}

export async function extendSessionExpiry(sessionId: string, expiresAt: Date) {
  return prisma.session.update({ where: { id: sessionId }, data: { expiresAt } });
}

// نکته: جدول sessions یک رکورد امنیتی/فنیِ گذراست، نه رکورد کسب‌وکاری قابل ممیزی؛
// به همین دلیل برخلاف بقیه‌ی Entityها اینجا Hard Delete مجاز است.
export async function deleteSessionByTokenHash(tokenHash: string) {
  return prisma.session.delete({ where: { tokenHash } }).catch(() => null);
}

export async function deleteAllSessionsForUser(userId: string) {
  return prisma.session.deleteMany({ where: { userId } });
}
