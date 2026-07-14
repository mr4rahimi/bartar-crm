import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { returnPurchaseSchema } from '@/features/purchases/validators/register-purchase.schema';
import { returnPurchaseService } from '@/features/purchases/services/purchase.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { purchaseId: string } };

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.RETURN_PURCHASE.code);

    const body = await request.json().catch(() => null);
    const parsed = returnPurchaseSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const purchase = await returnPurchaseService(params.purchaseId, parsed.data.reason, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(purchase);
  } catch (error) {
    return handleApiError(error, '[api/v1/purchases/:id/return POST]');
  }
}
