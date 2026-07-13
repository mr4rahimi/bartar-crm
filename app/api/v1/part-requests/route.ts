import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { partRequestQuerySchema } from '@/features/part-requests/validators/part-request-query.schema';
import { createPartRequestSchema } from '@/features/part-requests/validators/create-part-request.schema';
import {
  listPartRequestsService,
  createPartRequestService,
} from '@/features/part-requests/services/part-request.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_PART_REQUEST.code);

    const parsed = partRequestQuerySchema.safeParse(Object.fromEntries(request.nextUrl.searchParams));
    if (!parsed.success) return apiError('پارامترهای جستجو معتبر نیست', 400, zodIssues(parsed.error));

    return apiSuccess(await listPartRequestsService(parsed.data));
  } catch (error) {
    return handleApiError(error, '[api/v1/part-requests GET]');
  }
}

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.CREATE_PART_REQUEST.code);

    const body = await request.json().catch(() => null);
    const parsed = createPartRequestSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const created = await createPartRequestService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(created, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/part-requests POST]');
  }
}
