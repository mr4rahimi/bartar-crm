import bcrypt from 'bcryptjs';
import {
  listUsers,
  findUserById,
  findUserByPhone,
  createUser,
  updateUser,
  replaceUserRoles,
  softDeleteUser,
} from '../repositories/user.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { ConflictError, NotFoundError, ForbiddenError } from '@/shared/lib/errors';
import { toUserDto } from '../utils/user.mapper';
import type { CreateUserInput } from '../validators/create-user.schema';
import type { UpdateUserInput } from '../validators/update-user.schema';
import type { UserQueryInput } from '../validators/user-query.schema';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

export async function listUsersService(query: UserQueryInput) {
  const isActive = query.isActive === undefined ? undefined : query.isActive === 'true';

  const { items, total } = await listUsers({
    page: query.page,
    pageSize: query.pageSize,
    search: query.search,
    isActive,
  });

  return { items: items.map(toUserDto), total, page: query.page, pageSize: query.pageSize };
}

export async function getUserService(userId: string) {
  const user = await findUserById(userId);
  if (!user) throw new NotFoundError('کاربر یافت نشد');
  return toUserDto(user);
}

export async function createUserService(input: CreateUserInput, context: ActorContext) {
  const existing = await findUserByPhone(input.phone);
  if (existing) throw new ConflictError('کاربری با این شماره موبایل قبلاً ثبت شده است');

  const passwordHash = await bcrypt.hash(input.password, 12);

  const user = await createUser({
    name: input.name,
    phone: input.phone,
    email: input.email ?? null,
    passwordHash,
    isActive: input.isActive,
    roleIds: input.roleIds,
  });

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_USER',
    entityType: 'User',
    entityId: user.id,
    newValue: { name: user.name, phone: user.phone, roleIds: input.roleIds },
    ip: context.ip,
    device: context.device,
  });

  return toUserDto(user);
}

export async function updateUserService(
  userId: string,
  input: UpdateUserInput,
  context: ActorContext,
) {
  const existing = await findUserById(userId);
  if (!existing) throw new NotFoundError('کاربر یافت نشد');

  // Business Rule: کاربر نمی‌تواند حساب خودش را غیرفعال کند (جلوگیری از قفل شدن)
  if (userId === context.actorId && input.isActive === false) {
    throw new ForbiddenError('امکان غیرفعال کردن حساب خودتان وجود ندارد');
  }

  if (input.phone && input.phone !== existing.phone) {
    const phoneOwner = await findUserByPhone(input.phone);
    if (phoneOwner) throw new ConflictError('کاربری با این شماره موبایل قبلاً ثبت شده است');
  }

  const passwordHash = input.password ? await bcrypt.hash(input.password, 12) : undefined;

  await updateUser(userId, {
    name: input.name,
    phone: input.phone,
    email: input.email,
    passwordHash,
    isActive: input.isActive,
  });

  if (input.roleIds) {
    await replaceUserRoles(userId, input.roleIds);
  }

  const updated = await findUserById(userId);
  if (!updated) throw new NotFoundError('کاربر یافت نشد');

  await logActivity({
    userId: context.actorId,
    action: 'EDIT_USER',
    entityType: 'User',
    entityId: userId,
    previousValue: {
      name: existing.name,
      phone: existing.phone,
      email: existing.email,
      isActive: existing.isActive,
      roleIds: existing.roles.map((userRole) => userRole.roleId),
    },
    newValue: {
      name: updated.name,
      phone: updated.phone,
      email: updated.email,
      isActive: updated.isActive,
      roleIds: updated.roles.map((userRole) => userRole.roleId),
    },
    ip: context.ip,
    device: context.device,
  });

  return toUserDto(updated);
}

export async function deleteUserService(userId: string, context: ActorContext) {
  // Business Rule: کاربر نمی‌تواند حساب خودش را حذف کند
  if (userId === context.actorId) {
    throw new ForbiddenError('امکان حذف حساب خودتان وجود ندارد');
  }

  const existing = await findUserById(userId);
  if (!existing) throw new NotFoundError('کاربر یافت نشد');

  await softDeleteUser(userId);

  await logActivity({
    userId: context.actorId,
    action: 'DELETE_USER',
    entityType: 'User',
    entityId: userId,
    previousValue: { name: existing.name, phone: existing.phone },
    ip: context.ip,
    device: context.device,
  });
}
