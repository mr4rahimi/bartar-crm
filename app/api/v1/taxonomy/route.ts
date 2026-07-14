import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { getTaxonomyService } from '@/features/pricing/services/taxonomy.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

// تاکسونومی برای همه‌ی کاربران واردشده در دسترس است (فرم‌های ثبت به آن نیاز دارند)
export async function GET(request: NextRequest) {
  try {
    await authenticateRequest(request);
    return apiSuccess(await getTaxonomyService());
  } catch (error) {
    return handleApiError(error, '[api/v1/taxonomy GET]');
  }
}
