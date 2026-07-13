import { prisma } from '@/shared/lib/prisma';

const userWithPermissionsInclude = {
  roles: {
    include: {
      role: {
        include: {
          permissions: { include: { permission: true } },
        },
      },
    },
  },
} as const;

export async function findUserByPhone(phone: string) {
  return prisma.user.findFirst({
    where: { phone, deletedAt: null },
    include: userWithPermissionsInclude,
  });
}

export async function findUserById(userId: string) {
  return prisma.user.findFirst({
    where: { id: userId, deletedAt: null, isActive: true },
    include: userWithPermissionsInclude,
  });
}
