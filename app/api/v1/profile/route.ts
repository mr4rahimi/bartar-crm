import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { updateProfileSchema } from '@/features/users/validators/profile.schema';
import {
  getProfileService,
  updateProfileService,
} from '@/features/users/services/profile.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    return apiSuccess(await getProfileService(actor.id));
  } catch (error) {
    return handleApiError(error, '[api/v1/profile GET]');
  }
}

export async function PATCH(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);

    const body = await request.json().catch(() => null);
    const parsed = updateProfileSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات معتبر نیست', 400, zodIssues(parsed.error));

    const profile = await updateProfileService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(profile);
  } catch (error) {
    return handleApiError(error, '[api/v1/profile PATCH]');
  }
}
