import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { searchCustomersService } from '@/features/repairs/services/customer.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.CREATE_REPAIR.code);

    const search = request.nextUrl.searchParams.get('search') ?? '';
    return apiSuccess(await searchCustomersService(search));
  } catch (error) {
    return handleApiError(error, '[api/v1/customers GET]');
  }
}
