import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { listMyRepairsService } from '@/features/repairs/services/ticket.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'REPAIR_DEVICE');

    const params = request.nextUrl.searchParams;
    const statusParam = params.get('status');
    const status =
      statusParam === 'ASSIGNED' || statusParam === 'IN_PROGRESS' ? statusParam : undefined;
    const page = Number(params.get('page') ?? '1') || 1;

    return apiSuccess(
      await listMyRepairsService(actor.id, { status, page, pageSize: 50 }),
    );
  } catch (error) {
    return handleApiError(error, '[api/v1/my-repairs GET]');
  }
}
