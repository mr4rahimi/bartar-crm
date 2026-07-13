import type { Role, RolePermission, Permission } from '@prisma/client';
import type { RoleDto } from '../types/role.types';

type RoleWithRelations = Role & {
  permissions: (RolePermission & { permission: Permission })[];
  _count: { users: number };
};

export function toRoleDto(role: RoleWithRelations): RoleDto {
  return {
    id: role.id,
    name: role.name,
    description: role.description,
    permissions: role.permissions.map((rolePermission) => ({
      id: rolePermission.permission.id,
      code: rolePermission.permission.code,
      group: rolePermission.permission.group,
    })),
    userCount: role._count.users,
  };
}
