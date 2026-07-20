import type { NextRequest } from 'next/server';
import { z } from 'zod';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { applyTicketActionService } from '@/features/repairs/services/workflow.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

const actionSchema = z.object({
  action: z.enum(['ASSIGN', 'REASSIGN', 'ACCEPT', 'RETURN_TO_RECEPTION', 'HANDOFF']),
  technicianId: z.string().min(1).optional(),
  reason: z.string().trim().optional(),
});

type RouteParams = { params: { ticketId: string } };

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);

    const body = await request.json().catch(() => null);
    const parsed = actionSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات اقدام معتبر نیست', 400, zodIssues(parsed.error));

    const result = await applyTicketActionService(params.ticketId, parsed.data, {
      actorId: actor.id,
      permissions: actor.permissions,
      ...requestContext(request),
    });

    return apiSuccess(result.ticket);
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id/actions POST]');
  }
}
