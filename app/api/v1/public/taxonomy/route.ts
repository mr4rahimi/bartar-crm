import { getTaxonomyService } from '@/features/pricing/services/taxonomy.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

// صفحه عمومی قیمت‌ها — بدون احراز هویت (docs/15-pricing-integration.md)
export async function GET() {
  try {
    return apiSuccess(await getTaxonomyService());
  } catch (error) {
    return handleApiError(error, '[api/v1/public/taxonomy GET]');
  }
}
