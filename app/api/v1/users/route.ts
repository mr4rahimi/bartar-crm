import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { userQuerySchema } from '@/features/users/validators/user-query.schema';
import { createUserSchema } from '@/features/users/validators/create-user.schema';
import { listUsersService, createUserService } from '@/features/users/services/user.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_USER.code);

    const parsed = userQuerySchema.safeParse(Object.fromEntries(request.nextUrl.searchParams));
    if (!parsed.success) return apiError('پارامترهای جستجو معتبر نیست', 400, zodIssues(parsed.error));

    return apiSuccess(await listUsersService(parsed.data));
  } catch (error) {
    return handleApiError(error, '[api/v1/users GET]');
  }
}

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.CREATE_USER.code);

    const body = await request.json().catch(() => null);
    const parsed = createUserSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const user = await createUserService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(user, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/users POST]');
  }
}
