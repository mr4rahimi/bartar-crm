import { prisma } from '@/shared/lib/prisma';
import type { Prisma } from '@prisma/client';

const userWithRolesInclude = { roles: { include: { role: true } } } as const;

export type ListUsersParams = {
  page: number;
  pageSize: number;
  search?: string;
  isActive?: boolean;
};

export async function listUsers({ page, pageSize, search, isActive }: ListUsersParams) {
  const where: Prisma.UserWhereInput = {
    deletedAt: null,
    ...(isActive !== undefined && { isActive }),
    ...(search && {
      OR: [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
      ],
    }),
  };

  const [items, total] = await prisma.$transaction([
    prisma.user.findMany({
      where,
      include: userWithRolesInclude,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
    prisma.user.count({ where }),
  ]);

  return { items, total };
}

export async function findUserById(userId: string) {
  return prisma.user.findFirst({
    where: { id: userId, deletedAt: null },
    include: userWithRolesInclude,
  });
}

export async function findUserByPhone(phone: string) {
  return prisma.user.findFirst({ where: { phone, deletedAt: null } });
}

export type CreateUserData = {
  name: string;
  phone: string;
  email: string | null;
  passwordHash: string;
  isActive: boolean;
  roleIds: string[];
};

export async function createUser({ roleIds, ...data }: CreateUserData) {
  return prisma.user.create({
    data: { ...data, roles: { create: roleIds.map((roleId) => ({ roleId })) } },
    include: userWithRolesInclude,
  });
}

export type UpdateUserData = {
  name?: string;
  phone?: string;
  email?: string | null;
  passwordHash?: string;
  isActive?: boolean;
};

export async function updateUser(userId: string, data: UpdateUserData) {
  return prisma.user.update({
    where: { id: userId },
    data,
    include: userWithRolesInclude,
  });
}

// user_roles رکورد اتصال است نه رکورد کسب‌وکاری؛ تاریخچه‌ی تغییر در Activity Log ثبت می‌شود
export async function replaceUserRoles(userId: string, roleIds: string[]) {
  return prisma.$transaction([
    prisma.userRole.deleteMany({ where: { userId } }),
    prisma.userRole.createMany({ data: roleIds.map((roleId) => ({ userId, roleId })) }),
  ]);
}

export async function softDeleteUser(userId: string) {
  return prisma.user.update({
    where: { id: userId },
    data: { deletedAt: new Date(), isActive: false },
  });
}
