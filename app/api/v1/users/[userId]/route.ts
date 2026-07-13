import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { updateUserSchema } from '@/features/users/validators/update-user.schema';
import {
  getUserService,
  updateUserService,
  deleteUserService,
} from '@/features/users/services/user.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { userId: string } };

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_USER.code);

    return apiSuccess(await getUserService(params.userId));
  } catch (error) {
    return handleApiError(error, '[api/v1/users/:id GET]');
  }
}

export async function PATCH(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.EDIT_USER.code);

    const body = await request.json().catch(() => null);
    const parsed = updateUserSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    if (parsed.data.roleIds) {
      requirePermission(actor, PERMISSIONS.ASSIGN_ROLE.code);
    }

    const user = await updateUserService(params.userId, parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(user);
  } catch (error) {
    return handleApiError(error, '[api/v1/users/:id PATCH]');
  }
}

export async function DELETE(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.DELETE_USER.code);

    await deleteUserService(params.userId, { actorId: actor.id, ...requestContext(request) });

    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/users/:id DELETE]');
  }
}
