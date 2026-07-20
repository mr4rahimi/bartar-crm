import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { listTechniciansService } from '@/features/repairs/services/workflow.service';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

export async function GET(request: NextRequest) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, 'ASSIGN_REPAIR');
    return apiSuccess(await listTechniciansService());
  } catch (error) {
    return handleApiError(error, '[api/v1/technicians GET]');
  }
}
