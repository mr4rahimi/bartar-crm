import {
  findProfileById,
  updateProfile,
  updatePasswordHash,
  deleteOtherSessions,
} from '../repositories/profile.repository';
import { hashPassword, verifyPassword } from '@/features/authentication/utils/password.utils';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { NotFoundError, AppError } from '@/shared/lib/errors';
import type { ProfileDto } from '../types/profile.types';
import type { UpdateProfileInput, ChangePasswordInput } from '../validators/profile.schema';

type ActorContext = {
  actorId: string;
  tokenHash?: string;
  ip?: string | null;
  device?: string | null;
};

type ProfileRecord = Awaited<ReturnType<typeof findProfileById>>;

/** passwordHash هرگز از DTO عبور نمی‌کند */
function toProfileDto(user: NonNullable<ProfileRecord>): ProfileDto {
  return {
    id: user.id,
    name: user.name,
    phone: user.phone,
    avatarUrl: user.avatarUrl,
    roles: user.roles.map((item) => item.role.name),
    smsEnabled: user.smsEnabled,
    createdAt: user.createdAt,
  };
}

export async function getProfileService(userId: string) {
  const user = await findProfileById(userId);
  if (!user) throw new NotFoundError('کاربر یافت نشد');
  return toProfileDto(user);
}

export async function updateProfileService(input: UpdateProfileInput, context: ActorContext) {
  const current = await findProfileById(context.actorId);
  if (!current) throw new NotFoundError('کاربر یافت نشد');

  const user = await updateProfile(context.actorId, { name: input.name });

  await logActivity({
    userId: context.actorId,
    action: 'UPDATE_PROFILE',
    entityType: 'User',
    entityId: context.actorId,
    previousValue: { name: current.name } as never,
    newValue: { name: input.name } as never,
    ip: context.ip,
    device: context.device,
  });

  return toProfileDto(user);
}

export async function updateAvatarService(avatarUrl: string | null, context: ActorContext) {
  const current = await findProfileById(context.actorId);
  if (!current) throw new NotFoundError('کاربر یافت نشد');

  const user = await updateProfile(context.actorId, { avatarUrl });

  await logActivity({
    userId: context.actorId,
    action: avatarUrl ? 'UPDATE_AVATAR' : 'REMOVE_AVATAR',
    entityType: 'User',
    entityId: context.actorId,
    ip: context.ip,
    device: context.device,
  });

  return toProfileDto(user);
}

/** تغییر رمز با تایید رمز فعلی؛ سایر سشن‌ها بسته می‌شوند */
export async function changePasswordService(input: ChangePasswordInput, context: ActorContext) {
  const user = await findProfileById(context.actorId);
  if (!user) throw new NotFoundError('کاربر یافت نشد');

  const isValid = await verifyPassword(input.currentPassword, user.passwordHash);
  if (!isValid) throw new AppError('رمز فعلی اشتباه است', 400);

  await updatePasswordHash(context.actorId, await hashPassword(input.newPassword));

  // خروج از سایر دستگاه‌ها
  if (context.tokenHash) {
    await deleteOtherSessions(context.actorId, context.tokenHash);
  }

  await logActivity({
    userId: context.actorId,
    action: 'CHANGE_OWN_PASSWORD',
    entityType: 'User',
    entityId: context.actorId,
    ip: context.ip,
    device: context.device,
  });
}
