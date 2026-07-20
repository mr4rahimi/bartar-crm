import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { updateInvoiceSchema } from '@/features/invoices/validators/invoice.schema';
import {
  getInvoiceService,
  updateInvoiceService,
} from '@/features/invoices/services/invoice.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { invoiceId: string } };

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'VIEW_INVOICE');
    return apiSuccess(await getInvoiceService(params.invoiceId));
  } catch (error) {
    return handleApiError(error, '[api/v1/invoices/:id GET]');
  }
}

export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'MANAGE_INVOICE');

    const body = await request.json().catch(() => null);
    const parsed = updateInvoiceSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات فاکتور معتبر نیست', 400, zodIssues(parsed.error));

    const invoice = await updateInvoiceService(params.invoiceId, parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(invoice);
  } catch (error) {
    return handleApiError(error, '[api/v1/invoices/:id PATCH]');
  }
}
