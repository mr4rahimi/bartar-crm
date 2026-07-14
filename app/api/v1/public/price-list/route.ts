import type { NextRequest } from 'next/server';
import { getPriceListService } from '@/features/pricing/services/pricing.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

// لیست عمومی قیمت‌ها با جستجوی لایو — بدون احراز هویت، فقط قیمت فروش
export async function GET(request: NextRequest) {
  try {
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
        false,
      ),
    );
  } catch (error) {
    return handleApiError(error, '[api/v1/public/price-list GET]');
  }
}
