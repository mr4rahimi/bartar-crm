import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { setPriceSchema } from '@/features/pricing/validators/set-price.schema';
import {
  getModelPricesService,
  setPriceService,
} from '@/features/pricing/services/pricing.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_PRICE.code);

    const modelId = request.nextUrl.searchParams.get('modelId');
    if (!modelId) return apiError('مدل را انتخاب کنید', 400);

    // قیمت خرید فقط برای دارندگان EDIT_PRICE
    const includeBuy = actor.permissions.includes(PERMISSIONS.EDIT_PRICE.code);

    return apiSuccess(await getModelPricesService(modelId, includeBuy));
  } catch (error) {
    return handleApiError(error, '[api/v1/prices GET]');
  }
}

export async function PUT(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.EDIT_PRICE.code);

    const body = await request.json().catch(() => null);
    const parsed = setPriceSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    await setPriceService(parsed.data, { actorId: actor.id, ...requestContext(request) });

    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/prices PUT]');
  }
}
