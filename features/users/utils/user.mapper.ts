import type { User, UserRole, Role } from '@prisma/client';
import type { UserDto } from '../types/user.types';

type UserWithRoles = User & { roles: (UserRole & { role: Role })[] };

// passwordHash هرگز از این لایه عبور نمی‌کند
export function toUserDto(user: UserWithRoles): UserDto {
  return {
    id: user.id,
    name: user.name,
    phone: user.phone,
    email: user.email,
    isActive: user.isActive,
    smsEnabled: user.smsEnabled,
    roles: user.roles.map((userRole) => ({ id: userRole.role.id, name: userRole.role.name })),
    createdAt: user.createdAt,
  };
}
