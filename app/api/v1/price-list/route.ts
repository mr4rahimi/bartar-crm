import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { getPriceListService } from '@/features/pricing/services/pricing.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_PRICE.code);

    const includeBuy = actor.permissions.includes(PERMISSIONS.EDIT_PRICE.code);
    const params = request.nextUrl.searchParams;

    return apiSuccess(
      await getPriceListService(
        {
          page: Number(params.get('page') ?? '1') || 1,
          search: params.get('search') ?? undefined,
          deviceTypeId: params.get('deviceTypeId') ?? undefined,
          brandId: params.get('brandId') ?? undefined,
          partId: params.get('partId') ?? undefined,
        },
        includeBuy,
      ),
    );
  } catch (error) {
    return handleApiError(error, '[api/v1/price-list GET]');
  }
}
