'use client';

import { Dialog } from '@/shared/components/ui/dialog';
import { StatusBadge } from './ticket-table';
import { StatusTimeline } from './status-timeline';
import { StatusActions } from './status-actions';
import type { TicketDto } from '../types/ticket.types';

type StatusDialogProps = {
  ticket: TicketDto | null;
  assignedToId: string | null;
  currentUserId: string;
  permissions: string[];
  onClose: () => void;
};

export function StatusDialog({
  ticket,
  assignedToId,
  currentUserId,
  permissions,
  onClose,
}: StatusDialogProps) {
  if (!ticket) return null;

  return (
    <Dialog open onClose={onClose} title={`وضعیت قبض #${ticket.ticketNumber}`}>
      <div className="flex flex-col gap-4">
        <div className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-2.5">
          <span className="text-[12.5px] font-bold">{ticket.customer.name}</span>
          <StatusBadge ticket={ticket} />
        </div>

        <div>
          <h3 className="mb-2 text-[13px] font-extrabold">اقدام‌ها</h3>
          <StatusActions
            ticket={ticket}
            assignedToId={assignedToId}
            currentUserId={currentUserId}
            permissions={permissions}
            onDone={onClose}
          />
        </div>

        <div>
          <h3 className="mb-2 text-[13px] font-extrabold">مراحل</h3>
          <StatusTimeline ticketId={ticket.id} />
        </div>
      </div>
    </Dialog>
  );
}
