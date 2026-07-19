import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { getReceptionCatalogService } from '@/features/repairs/services/reception-catalog.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    await authenticateRequest(request);
    const deviceTypeId = request.nextUrl.searchParams.get('deviceTypeId') ?? undefined;
    return apiSuccess(await getReceptionCatalogService(deviceTypeId));
  } catch (error) {
    return handleApiError(error, '[api/v1/reception-catalog GET]');
  }
}
