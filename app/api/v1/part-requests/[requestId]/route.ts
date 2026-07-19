import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import {
  getPartRequestService,
  updatePartRequestService,
} from '@/features/part-requests/services/part-request.service';
import { updatePartRequestSchema } from '@/features/part-requests/validators/update-part-request.schema';
import { requestContext } from '@/shared/lib/request-context';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

type RouteParams = { params: { requestId: string } };

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_PART_REQUEST.code);

    return apiSuccess(await getPartRequestService(params.requestId));
  } catch (error) {
    return handleApiError(error, '[api/v1/part-requests/:id GET]');
  }
}

export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'EDIT_PART_REQUEST');

    const body = await request.json().catch(() => null);
    const parsed = updatePartRequestSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const updated = await updatePartRequestService(params.requestId, parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(updated);
  } catch (error) {
    return handleApiError(error, '[api/v1/part-requests/:id PATCH]');
  }
}
