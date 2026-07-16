import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { requestContext } from '@/shared/lib/request-context';

// مدیریت کاتالوگ با EDIT_PRICE کنترل می‌شود (بدون افزودن Permission جدید به Schema)
export async function authorizeCatalog(request: NextRequest) {
  const actor = await authenticateRequest(request);
  requirePermission(actor, PERMISSIONS.EDIT_PRICE.code);
  return { actorId: actor.id, ...requestContext(request) };
}
