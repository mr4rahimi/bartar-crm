import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { createRoleSchema } from '@/features/permissions/validators/role.schema';
import { listRolesService, createRoleService } from '@/features/permissions/services/role.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.ASSIGN_ROLE.code);

    return apiSuccess(await listRolesService());
  } catch (error) {
    return handleApiError(error, '[api/v1/roles GET]');
  }
}

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.CREATE_ROLE.code);

    const body = await request.json().catch(() => null);
    const parsed = createRoleSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const role = await createRoleService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(role, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/roles POST]');
  }
}
