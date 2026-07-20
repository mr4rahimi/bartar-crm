'use client';

import { cn } from '@/shared/lib/cn';
import { TICKET_STATUS_LABELS } from '../constants/ticket-status.constants';
import { TICKET_ACTION_LABELS } from '../constants/workflow.constants';
import { useTicketHistory } from '../hooks/use-workflow';

export function StatusTimeline({ ticketId, enabled = true }: { ticketId: string; enabled?: boolean }) {
  const history = useTicketHistory(ticketId, enabled);

  if (history.isLoading) {
    return <p className="py-3 text-center text-[12px] text-muted-foreground">در حال بارگذاری…</p>;
  }
  if (!history.data || history.data.length === 0) {
    return <p className="py-3 text-center text-[12px] text-muted-foreground">تغییری ثبت نشده</p>;
  }

  return (
    <div className="space-y-0">
      {history.data.map((entry, index) => (
        <div key={entry.id} className="relative flex gap-3 pb-4 last:pb-0">
          <div className="flex flex-col items-center">
            <span
              className={cn(
                'mt-1 h-2.5 w-2.5 rounded-full',
                index === 0 ? 'bg-primary' : 'bg-muted-foreground/40',
              )}
            />
            {index < history.data.length - 1 && <span className="w-px flex-1 bg-border" />}
          </div>
          <div className="pb-1">
            <div className="text-[13px] font-bold">
              {TICKET_ACTION_LABELS[entry.action] ?? TICKET_STATUS_LABELS[entry.newStatus]}
            </div>
            <div className="text-[11.5px] text-muted-foreground">
              {entry.changedByName} — {new Date(entry.createdAt).toLocaleString('fa-IR')}
            </div>
            {entry.description && (
              <div className="mt-0.5 text-[12px] text-muted-foreground">{entry.description}</div>
            )}
          </div>
        </div>
      ))}
    </div>
  );
}
