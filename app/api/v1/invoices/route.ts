import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { invoiceSchema } from '@/features/invoices/validators/invoice.schema';
import { createInvoiceService } from '@/features/invoices/services/invoice.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'MANAGE_INVOICE');

    const body = await request.json().catch(() => null);
    const parsed = invoiceSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات فاکتور معتبر نیست', 400, zodIssues(parsed.error));

    const invoice = await createInvoiceService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(invoice, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/invoices POST]');
  }
}
