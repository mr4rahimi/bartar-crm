import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { getPriceHistoryService } from '@/features/pricing/services/pricing.service';
import { apiSuccess, apiError } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_PRICE_HISTORY.code);

    const modelId = request.nextUrl.searchParams.get('modelId');
    const partId = request.nextUrl.searchParams.get('partId');
    if (!modelId || !partId) return apiError('مدل و قطعه را مشخص کنید', 400);

    return apiSuccess(await getPriceHistoryService(modelId, partId));
  } catch (error) {
    return handleApiError(error, '[api/v1/prices/history GET]');
  }
}
