import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { getCatalogService } from '@/features/pricing/services/catalog.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.EDIT_PRICE.code);
    return apiSuccess(await getCatalogService());
  } catch (error) {
    return handleApiError(error, '[api/v1/catalog GET]');
  }
}
