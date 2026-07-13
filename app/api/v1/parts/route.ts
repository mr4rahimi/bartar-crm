import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { listPartOptionsService } from '@/features/part-requests/services/part-request.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_PART_REQUEST.code);

    return apiSuccess(await listPartOptionsService());
  } catch (error) {
    return handleApiError(error, '[api/v1/parts GET]');
  }
}
