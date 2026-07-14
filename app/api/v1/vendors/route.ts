import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requireAnyPermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import {
  listVendorsService,
  createVendorService,
} from '@/features/purchases/services/purchase.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';
import { z } from 'zod';
import { phoneSchema } from '@/shared/validators/phone.schema';

const createVendorSchema = z.object({
  name: z.string().trim().min(2, 'نام فروشنده باید حداقل ۲ کاراکتر باشد'),
  phone: phoneSchema.optional(),
});

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requireAnyPermission(actor, [
      PERMISSIONS.VIEW_VENDOR.code,
      PERMISSIONS.REGISTER_PURCHASE.code,
    ]);

    return apiSuccess(await listVendorsService());
  } catch (error) {
    return handleApiError(error, '[api/v1/vendors GET]');
  }
}

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requireAnyPermission(actor, [
      PERMISSIONS.CREATE_VENDOR.code,
      PERMISSIONS.REGISTER_PURCHASE.code,
    ]);

    const body = await request.json().catch(() => null);
    const parsed = createVendorSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));

    const vendor = await createVendorService(parsed.data, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(vendor, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/vendors POST]');
  }
}
