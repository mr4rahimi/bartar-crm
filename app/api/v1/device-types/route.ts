import type { NextRequest } from 'next/server';
import { nameSchema } from '@/features/pricing/validators/catalog.schema';
import { createDeviceTypeService } from '@/features/pricing/services/catalog.service';
import { authorizeCatalog } from '@/features/pricing/utils/catalog-route.helper';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function POST(request: NextRequest) {
  try {
    const context = await authorizeCatalog(request);
    const body = await request.json().catch(() => null);
    const parsed = nameSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));
    return apiSuccess(await createDeviceTypeService(parsed.data.name, context), 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/device-types POST]');
  }
}
