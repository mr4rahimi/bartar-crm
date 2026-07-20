import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { getTicketHistoryService } from '@/features/repairs/services/workflow.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

type RouteParams = { params: { ticketId: string } };

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_REPAIR.code);
    return apiSuccess(await getTicketHistoryService(params.ticketId));
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id/history GET]');
  }
}
