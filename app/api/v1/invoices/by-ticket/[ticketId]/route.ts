import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { getInvoiceByTicketService } from '@/features/invoices/services/invoice.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

type RouteParams = { params: { ticketId: string } };

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'VIEW_INVOICE');
    return apiSuccess(await getInvoiceByTicketService(params.ticketId));
  } catch (error) {
    return handleApiError(error, '[api/v1/invoices/by-ticket/:id GET]');
  }
}
