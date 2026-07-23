import { writeFile, unlink, mkdir } from 'node:fs/promises';
import path from 'node:path';
import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import {
  getProfileService,
  updateAvatarService,
} from '@/features/users/services/profile.service';
import { apiSuccess, apiError } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

const MAX_SIZE = 2 * 1024 * 1024; // ۲ مگابایت
const ALLOWED = new Map([
  ['image/jpeg', 'jpg'],
  ['image/png', 'png'],
  ['image/webp', 'webp'],
]);

const UPLOAD_DIR = path.join(process.cwd(), 'public', 'uploads', 'avatars');

/** حذف فایل قبلی — خطا نادیده گرفته می‌شود */
async function removeOldAvatar(avatarUrl: string | null) {
  if (!avatarUrl?.startsWith('/uploads/avatars/')) return;
  try {
    await unlink(path.join(process.cwd(), 'public', avatarUrl));
  } catch {
    // فایل وجود ندارد
  }
}

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);

    const formData = await request.formData();
    const file = formData.get('file');
    if (!(file instanceof File)) return apiError('فایلی ارسال نشده است', 400);
    if (file.size > MAX_SIZE) return apiError('حجم تصویر نباید بیش از ۲ مگابایت باشد', 400);

    const extension = ALLOWED.get(file.type);
    if (!extension) return apiError('فرمت تصویر باید JPG، PNG یا WebP باشد', 400);

    const current = await getProfileService(actor.id);

    await mkdir(UPLOAD_DIR, { recursive: true });
    const fileName = `${actor.id}-${Date.now()}.${extension}`;
    const buffer = Buffer.from(await file.arrayBuffer());
    await writeFile(path.join(UPLOAD_DIR, fileName), buffer);

    await removeOldAvatar(current.avatarUrl);

    const profile = await updateAvatarService(`/uploads/avatars/${fileName}`, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(profile);
  } catch (error) {
    return handleApiError(error, '[api/v1/profile/avatar POST]');
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);

    const current = await getProfileService(actor.id);
    await removeOldAvatar(current.avatarUrl);

    const profile = await updateAvatarService(null, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(profile);
  } catch (error) {
    return handleApiError(error, '[api/v1/profile/avatar DELETE]');
  }
}
