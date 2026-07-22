import type { NextRequest } from 'next/server';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import { listQualityChecks } from '@/features/repairs/repositories/quality-check.repository';
import { apiSuccess } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';

type RouteParams = { params: { ticketId: string } };

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_REPAIR.code);

    const checks = await listQualityChecks(params.ticketId);
    return apiSuccess(
      checks.map((check) => ({
        id: check.id,
        notes: check.notes,
        passed: check.passed,
        checkedByName: check.checkedBy.name,
        createdAt: check.createdAt,
      })),
    );
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id/quality-checks GET]');
  }
}
