import type { NextRequest } from 'next/server';
import { z } from 'zod';
import {
  authenticateRequest,
  requirePermission,
} from '@/features/authentication/services/authorize.service';
import { PERMISSIONS } from '@/features/permissions/constants/permission-codes.constants';
import {
  listRepairNotesService,
  addRepairNoteService,
} from '@/features/repairs/services/repair-note.service';
import { apiSuccess, apiError, zodIssues } from '@/shared/lib/api-response';
import { handleApiError } from '@/shared/lib/handle-api-error';
import { requestContext } from '@/shared/lib/request-context';

type RouteParams = { params: { ticketId: string } };

const noteSchema = z.object({ body: z.string().trim().min(1, 'متن یادداشت را وارد کنید') });

export async function GET(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_REPAIR.code);
    return apiSuccess(await listRepairNotesService(params.ticketId));
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id/notes GET]');
  }
}

export async function POST(request: NextRequest, { params }: RouteParams) {
  try {
    const actor = await authenticateRequest(request);
    requirePermission(actor, PERMISSIONS.VIEW_REPAIR.code);

    const body = await request.json().catch(() => null);
    const parsed = noteSchema.safeParse(body);
    if (!parsed.success) return apiError('اطلاعات معتبر نیست', 400, zodIssues(parsed.error));

    const note = await addRepairNoteService(params.ticketId, parsed.data.body, {
      actorId: actor.id,
      ...requestContext(request),
    });

    return apiSuccess(note, 201);
  } catch (error) {
    return handleApiError(error, '[api/v1/repair-tickets/:id/notes POST]');
  }
}
