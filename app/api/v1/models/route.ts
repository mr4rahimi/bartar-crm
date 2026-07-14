import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { createModelSchema } from '@/features/pricing/validators/create-model.schema';
import { createModelService } from '@/features/pricing/services/taxonomy.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    // هر کسی که می‌تواند درخواست قطعه ثبت کند، می‌تواند مدل جاافتاده را هم بسازد
    requirePermission(actor, PERMISSIONS.CREATE_PART_REQUEST.code);

    const body = await request.json().catch(() => null);
    const parsed = createModelSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const model = await createModelService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(model, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/models POST]');
  }
}
