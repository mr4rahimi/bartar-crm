import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requireAnyPermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { getEntityLogsService } from '@/features/activity-logs/services/activity-query.service';
import { apiSuccess, apiError } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requireAnyPermission(actor, [PERMISSIONS.VIEW_ACTIVITY_LOG.code, 'EDIT_PART_REQUEST']);

    const entityType = request.nextUrl.searchParams.get('entityType');
    const entityId = request.nextUrl.searchParams.get('entityId');
    if (!entityType || !entityId) return apiError('پارامترهای لاگ معتبر نیست', 400);

    return apiSuccess(await getEntityLogsService(entityType, entityId));
  } catch (error) {
    return handleApiError(error, '[api/v1/activity-logs GET]');
  }
}
