import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requireAnyPermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { nameSchema } from '@/features/pricing/validators/catalog.schema';
import { createPartService } from '@/features/pricing/services/catalog.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

// ساخت قطعه از فرم درخواست — ثبت‌کننده‌ی درخواست نباید وسط کار گیر کند
export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requireAnyPermission(actor, [
      PERMISSIONS.CREATE_PART_REQUEST.code,
      PERMISSIONS.EDIT_PRICE.code,
    ]);

    const body = await request.json().catch(() => null);
    const parsed = nameSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const part = await createPartService(parsed.data.name, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess({ id: part.id, name: part.name }, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/parts-quick POST]');
  }
}