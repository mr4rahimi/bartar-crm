import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { SESSION_COOKIE_NAME } from '@/features/authentication/constants/session.constants';
import { hashToken } from '@/features/authentication/utils/token.utils';
import { changePasswordSchema } from '@/features/users/validators/profile.schema';
import { changePasswordService } from '@/features/users/services/profile.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);

    const body = await request.json().catch(() => null);
    const parsed = changePasswordSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات معتبر نیست', 400, zodIssues(parsed.error));

    // سشن فعلی حفظ می‌شود، بقیه بسته می‌شوند
    const rawToken = request.cookies.get(SESSION_COOKIE_NAME)?.value;

    await changePasswordService(parsed.data, {
      actorId: actor.id,
      tokenHash: rawToken ? hashToken(rawToken) : undefined,
      ...requestContext(request),
    });

    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/profile/password POST]');
  }
}
