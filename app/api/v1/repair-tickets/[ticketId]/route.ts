import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { updateTicketSchema } from '@/features/repairs/validators/update-ticket.schema';
import {
  getTicketService,
  updateTicketService,
  deleteTicketService,
} from '@/features/repairs/services/ticket.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { ticketId: string } };

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_REPAIR.code);
    return apiSuccess(await getTicketService(params.ticketId));
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id GET]');
  }
}

export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'EDIT_REPAIR');

    const body = await request.json().catch(() => null);
    const parsed = updateTicketSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const ticket = await updateTicketService(params.ticketId, parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(ticket);
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id PATCH]');
  }
}

export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'DELETE_REPAIR');

    await deleteTicketService(params.ticketId, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id DELETE]');
  }
}
