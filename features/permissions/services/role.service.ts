import {
  listRoles,
  findRoleById,
  findRoleByName,
  createRole,
  updateRole,
  replaceRolePermissions,
  softDeleteRole,
} from '../repositories/role.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { ConflictError, NotFoundError } from '@/shared/lib/errors';
import { toRoleDto } from '../utils/role.mapper';
import type { CreateRoleInput, UpdateRoleInput } from '../validators/role.schema';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

export async function listRolesService() {
  const roles = await listRoles();
  return roles.map(toRoleDto);
}

export async function createRoleService(input: CreateRoleInput, context: ActorContext) {
  const existing = await findRoleByName(input.name);
  if (existing) throw new ConflictError('نقشی با این نام قبلاً ثبت شده است');

  const role = await createRole({
    name: input.name,
    description: input.description ?? null,
    permissionIds: input.permissionIds,
  });

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_ROLE',
    entityType: 'Role',
    entityId: role.id,
    newValue: { name: role.name, permissionIds: input.permissionIds },
    ip: context.ip,
    device: context.device,
  });

  return toRoleDto(role);
}

export async function updateRoleService(
  roleId: string,
  input: UpdateRoleInput,
  context: ActorContext,
) {
  const existing = await findRoleById(roleId);
  if (!existing) throw new NotFoundError('نقش یافت نشد');

  if (input.name && input.name !== existing.name) {
    const nameOwner = await findRoleByName(input.name);
    if (nameOwner) throw new ConflictError('نقشی با این نام قبلاً ثبت شده است');
  }

  await updateRole(roleId, { name: input.name, description: input.description });

  if (input.permissionIds) {
    await replaceRolePermissions(roleId, input.permissionIds);
  }

  const updated = await findRoleById(roleId);
  if (!updated) throw new NotFoundError('نقش یافت نشد');

  await logActivity({
    userId: context.actorId,
    action: 'EDIT_ROLE',
    entityType: 'Role',
    entityId: roleId,
    previousValue: {
      name: existing.name,
      permissionIds: existing.permissions.map((rp) => rp.permissionId),
    },
    newValue: {
      name: updated.name,
      permissionIds: updated.permissions.map((rp) => rp.permissionId),
    },
    ip: context.ip,
    device: context.device,
  });

  return toRoleDto(updated);
}

export async function deleteRoleService(roleId: string, context: ActorContext) {
  const existing = await findRoleById(roleId);
  if (!existing) throw new NotFoundError('نقش یافت نشد');

  // Business Rule: نقشی که به کاربری اختصاص داده شده قابل حذف نیست
  if (existing._count.users > 0) {
    throw new ConflictError('این نقش به کاربرانی اختصاص داده شده و قابل حذف نیست');
  }

  await softDeleteRole(roleId);

  await logActivity({
    userId: context.actorId,
    action: 'DELETE_ROLE',
    entityType: 'Role',
    entityId: roleId,
    previousValue: { name: existing.name },
    ip: context.ip,
    device: context.device,
  });
}
