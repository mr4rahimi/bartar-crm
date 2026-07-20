import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { markAllReadService } from '@/features/notifications/services/inapp.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function POST(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    await markAllReadService(actor.id);
    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/notifications/read-all POST]');
  }
}
