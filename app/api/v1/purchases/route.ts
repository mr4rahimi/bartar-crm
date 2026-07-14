import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { registerPurchaseSchema } from '@/features/purchases/validators/register-purchase.schema';
import {
  listPurchasesService,
  registerPurchaseService,
} from '@/features/purchases/services/purchase.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.REGISTER_PURCHASE.code);

    const page = Number(request.nextUrl.searchParams.get('page') ?? '1') || 1;
    return apiSuccess(await listPurchasesService(page));
  } catch (error) {
    return handleApiError(error, '[api/v1/purchases GET]');
  }
}

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.REGISTER_PURCHASE.code);

    const body = await request.json().catch(() => null);
    const parsed = registerPurchaseSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const result = await registerPurchaseService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(result, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/purchases POST]');
  }
}
