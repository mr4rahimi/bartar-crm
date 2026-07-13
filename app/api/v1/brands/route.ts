import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { listCatalogService } from '@/features/repairs/services/ticket.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.CREATE_REPAIR.code);

    return apiSuccess(await listCatalogService());
  } catch (error) {
    return handleApiError(error, '[api/v1/brands GET]');
  }
}
