import { createRepairNote, listRepairNotes } from '../repositories/repair-note.repository';
import { findAnyTicketById } from '../repositories/ticket.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { NotFoundError, AppError } from '@/shared/lib/errors';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

export async function listRepairNotesService(ticketId: string) {
  const notes = await listRepairNotes(ticketId);
  return notes.map((note) => ({
    id: note.id,
    body: note.body,
    authorName: note.author.name,
    createdAt: note.createdAt,
  }));
}

export async function addRepairNoteService(
  ticketId: string,
  body: string,
  context: ActorContext,
) {
  const trimmed = body.trim();
  if (!trimmed) throw new AppError('متن یادداشت خالی است', 400);

  const ticket = await findAnyTicketById(ticketId);
  if (!ticket) throw new NotFoundError('قبض پذیرش یافت نشد');

  const note = await createRepairNote({ ticketId, authorId: context.actorId, body: trimmed });

  await logActivity({
    userId: context.actorId,
    action: 'ADD_REPAIR_NOTE',
    entityType: 'RepairTicket',
    entityId: ticketId,
    newValue: { note: trimmed.slice(0, 120) } as never,
    ip: context.ip,
    device: context.device,
  });

  return {
    id: note.id,
    body: note.body,
    authorName: note.author.name,
    createdAt: note.createdAt,
  };
}
