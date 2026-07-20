import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { getInboxService } from '@/features/notifications/services/inapp.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    return apiSuccess(await getInboxService(actor.id));
  } catch (error) {
    return handleApiError(error, '[api/v1/notifications GET]');
  }
}
