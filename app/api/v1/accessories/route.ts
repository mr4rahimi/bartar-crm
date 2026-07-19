import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { catalogItemSchema } from '@/features/repairs/validators/catalog-item.schema';
import { createAccessoryService } from '@/features/repairs/services/reception-catalog.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.CREATE_REPAIR.code);

    const body = await request.json().catch(() => null);
    const parsed = catalogItemSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const accessory = await createAccessoryService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(accessory, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/accessories POST]');
  }
}
