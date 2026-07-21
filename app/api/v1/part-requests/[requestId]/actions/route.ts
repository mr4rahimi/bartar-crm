import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { partRequestActionSchema } from '@/features/part-requests/validators/part-request-action.schema';
import { findActionDef } from '@/features/part-requests/constants/state-machine.constants';
import { applyPartRequestActionService } from '@/features/part-requests/services/part-request.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { requestId: string } };

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);

    const body = await request.json().catch(() => null);
    const parsed = partRequestActionSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    // برای گذارهای «فقط درخواست‌دهنده»، بررسی نهایی در سرویس انجام می‌شود
    const actionDef = findActionDef(parsed.data.action);
    if (!actionDef.requesterOnly) {
      requirePermission(actor, actionDef.permission);
    }

    const updated = await applyPartRequestActionService(params.requestId, parsed.data, {
      actorId: actor.id,
      permissions: actor.permissions,
      ...requestContext(request),
    });

    return apiSuccess(updated);
  } catch (error) {
    return handleApiError(error, '[api/v1/part-requests/:id/actions POST]');
  }
}
