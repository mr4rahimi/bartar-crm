import type { NextRequest } from 'next/server';
import { getModelPricesService } from '@/features/pricing/services/pricing.service';
import { apiSuccess, apiError } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

// فقط قیمت فروش — بدون احراز هویت
export async function GET(request: NextRequest) {
  try {
    const modelId = request.nextUrl.searchParams.get('modelId');
    if (!modelId) return apiError('مدل را انتخاب کنید', 400);

    return apiSuccess(await getModelPricesService(modelId, false));
  } catch (error) {
    return handleApiError(error, '[api/v1/public/prices GET]');
  }
}
