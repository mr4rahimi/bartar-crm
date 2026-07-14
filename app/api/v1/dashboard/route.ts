import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { getDashboardService } from '@/features/dashboard/services/dashboard.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

// آمار تجمیعی داخلی — برای همه‌ی کاربران واردشده
export async function GET(request: NextRequest) {
  try {
    await authenticateRequest(request);
    return apiSuccess(await getDashboardService());
  } catch (error) {
    return handleApiError(error, '[api/v1/dashboard GET]');
  }
}
