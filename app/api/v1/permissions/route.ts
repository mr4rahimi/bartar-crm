import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { listPermissionsService } from '@/features/permissions/services/permission.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.ASSIGN_PERMISSION.code);

    return apiSuccess(await listPermissionsService());
  } catch (error) {
    return handleApiError(error, '[api/v1/permissions GET]');
  }
}
