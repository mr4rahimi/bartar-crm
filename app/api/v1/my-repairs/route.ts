import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import {
  listMyRepairsService,
  type MyRepairsTab,
} from '@/features/repairs/services/ticket.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

const TABS: MyRepairsTab[] = [
  'ASSIGNED',
  'IN_PROGRESS',
  'QUALITY_CHECK',
  'HANDOVER',
  'HISTORY',
];

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'REPAIR_DEVICE');

    const params = request.nextUrl.searchParams;
    const tabParam = params.get('tab') as MyRepairsTab | null;
    const tab = tabParam && TABS.includes(tabParam) ? tabParam : 'ASSIGNED';
    const page = Number(params.get('page') ?? '1') || 1;

    return apiSuccess(await listMyRepairsService(actor.id, { tab, page, pageSize: 50 }));
  } catch (error) {
    return handleApiError(error, '[api/v1/my-repairs GET]');
  }
}
