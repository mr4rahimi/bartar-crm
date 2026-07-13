import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { updateRoleSchema } from '@/features/permissions/validators/role.schema';
import {
  updateRoleService,
  deleteRoleService,
} from '@/features/permissions/services/role.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { roleId: string } };

export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.EDIT_ROLE.code);

    const body = await request.json().catch(() => null);
    const parsed = updateRoleSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    if (parsed.data.permissionIds) {
      requirePermission(actor, PERMISSIONS.ASSIGN_PERMISSION.code);
    }

    const role = await updateRoleService(params.roleId, parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(role);
  } catch (error) {
    return handleApiError(error, '[api/v1/roles/:id PATCH]');
  }
}

export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.DELETE_ROLE.code);

    await deleteRoleService(params.roleId, { actorId: actor.id, ...requestContext(request) });

    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/roles/:id DELETE]');
  }
}
