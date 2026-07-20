import type { NextRequest } from 'next/server';
import { authenticateRequest } from '@/features/authentication/services/authorize.service';
import { markReadService } from '@/features/notifications/services/inapp.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

type RouteParams = { params: { notificationId: string } };

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    await markReadService(actor.id, params.notificationId);
    return apiSuccess(null);
  } catch (error) {
    return handleApiError(error, '[api/v1/notifications/:id/read POST]');
  }
}
