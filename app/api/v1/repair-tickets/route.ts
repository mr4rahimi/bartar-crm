import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { ticketQuerySchema } from '@/features/repairs/validators/ticket-query.schema';
import { createTicketSchema } from '@/features/repairs/validators/create-ticket.schema';
import {
  listTicketsService,
  createTicketService,
} from '@/features/repairs/services/ticket.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_REPAIR.code);

    const parsed = ticketQuerySchema.safeParse(Object.fromEntries(request.nextUrl.searchParams));
    if (!parsed.success) return apiError('پارامترهای جستجو معتبر نیست', 400, zodIssues(parsed.error));

    // مشاهده حذف‌شده‌ها فقط با DELETE_REPAIR
    if (parsed.data.deleted) requirePermission(actor, 'DELETE_REPAIR');

    return apiSuccess(await listTicketsService(parsed.data));
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets GET]');
  }
}

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.CREATE_REPAIR.code);

    const body = await request.json().catch(() => null);
    const parsed = createTicketSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const ticket = await createTicketService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(ticket, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets POST]');
  }
}
