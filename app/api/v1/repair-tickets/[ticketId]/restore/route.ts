import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { restoreTicketService } from '@/features/repairs/services/ticket.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { ticketId: string } };

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'DELETE_REPAIR');

    const ticket = await restoreTicketService(params.ticketId, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(ticket);
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id/restore POST]');
  }
}
