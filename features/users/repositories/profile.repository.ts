import { prisma } from '@/shared/lib/prisma';

/** اطلاعات پروفایل خود کاربر — passwordHash فقط برای بررسی رمز فعلی */
export async function findProfileById(userId: string) {
  return prisma.user.findFirst({
    where: { id: userId, deletedAt: null },
    include: { roles: { include: { role: true } } },
  });
}

export async function updateProfile(
  userId: string,
  data: { name?: string; avatarUrl?: string | null },
) {
  return prisma.user.update({
    where: { id: userId },
    data,
    include: { roles: { include: { role: true } } },
  });
}

export async function updatePasswordHash(userId: string, passwordHash: string) {
  return prisma.user.update({ where: { id: userId }, data: { passwordHash } });
}

/** حذف همه‌ی سشن‌های کاربر جز سشن فعلی (پس از تغییر رمز) */
export async function deleteOtherSessions(userId: string, keepTokenHash: string) {
  return prisma.session.deleteMany({
    where: { userId, tokenHash: { not: keepTokenHash } },
  });
}
