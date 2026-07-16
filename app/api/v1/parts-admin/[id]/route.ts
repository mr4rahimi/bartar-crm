import type { NextRequest } from 'next/server';
import { nameSchema } from '@/features/pricing/validators/catalog.schema';
import { updatePartService, deletePartService } from '@/features/pricing/services/catalog.service';
import { authorizeCatalog } from '@/features/pricing/utils/catalog-route.helper';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

type Params = { params: { id: string } };

export async function PATCH(request: NextRequest, { params }: Params) {
  try {
    const context = await authorizeCatalog(request);
    const body = await request.json().catch(() => null);
    const parsed = nameSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات ورودی معتبر نیست', 400, zodIssues(parsed.error));
    return apiSuccess(await updatePartService(params.id, parsed.data.name, context));
  } catch (error) {
    return handleApiError(error, '[api/v1/parts-admin/:id PATCH]');
  }
}

export async function DELETE(request: NextRequest, { params }: Params) {
  try {
    const context = await authorizeCatalog(request);
    await deletePartService(params.id, context);
    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/parts-admin/:id DELETE]');
  }
}
