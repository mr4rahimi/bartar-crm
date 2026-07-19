import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { checkAnnouncedPriceService } from '@/features/pricing/services/pricing.service';
import { apiSuccess, apiError } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

const QUALITIES = ['ORIGINAL', 'HIGH_COPY', 'COPY'] as const;
type Quality = (typeof QUALITIES)[number];

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_PART_REQUEST.code);

    const params = request.nextUrl.searchParams;
    const modelId = params.get('modelId');
    const partId = params.get('partId');
    const quality = params.get('quality') as Quality | null;
    const price = Number(params.get('price') ?? '0');

    if (!modelId || !partId || !quality || !QUALITIES.includes(quality) || price <= 0) {
      return apiError('پارامترهای بررسی قیمت معتبر نیست', 400);
    }

    return apiSuccess(
      await checkAnnouncedPriceService({
        modelId,
        partId,
        quality,
        price,
        includeBuyPrice: actor.permissions.includes(PERMISSIONS.EDIT_PRICE.code),
      }),
    );
  } catch (error) {
    return handleApiError(error, '[api/v1/part-prices/check GET]');
  }
}
