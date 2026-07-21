'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Clock, KeyRound, PackagePlus, Smartphone } from 'lucide-react';
import { PartRequestFormDialog } from '@/features/part-requests/components/part-request-form-dialog';
import { StatusBadge } from './ticket-table';
import { StatusActions } from './status-actions';
import type { TicketDto } from '../types/ticket.types';

const relativeTime = (value: Date | string) => {
  const diff = Date.now() - new Date(value).getTime();
  const hours = Math.floor(diff / 3_600_000);
  if (hours < 1) return 'کمتر از یک ساعت پیش';
  if (hours < 24) return `${hours.toLocaleString('fa-IR')} ساعت پیش`;
  const days = Math.floor(hours / 24);
  return `${days.toLocaleString('fa-IR')} روز پیش`;
};

type MyRepairCardProps = {
  ticket: TicketDto;
  currentUserId: string;
  permissions: string[];
  onChanged: () => void;
};

export function MyRepairCard({ ticket, currentUserId, permissions, onChanged }: MyRepairCardProps) {
  const router = useRouter();
  const [isPartFormOpen, setIsPartFormOpen] = useState(false);

  const deviceTitle = [ticket.device.deviceType, ticket.device.brand, ticket.device.model]
    .filter(Boolean)
    .join(' ');

  return (
    <div className="rounded-lg border border-border bg-card p-4">
      <div className="flex items-start justify-between gap-2">
        <button
          type="button"
          onClick={() => router.push('/repairs/' + ticket.id)}
          className="text-right"
        >
          <div className="flex items-center gap-2">
            <span className="text-[14px] font-extrabold text-primary">#{ticket.ticketNumber}</span>
            <span className="text-[13px] font-bold">{ticket.customer.name}</span>
          </div>
          <div className="mt-1 flex items-center gap-1.5 text-[12.5px] text-muted-foreground">
            <Smartphone className="h-3.5 w-3.5" />
            {deviceTitle}
          </div>
        </button>
        <StatusBadge ticket={ticket} />
      </div>

      {ticket.issues.length > 0 && (
        <div className="mt-2.5 flex flex-wrap gap-1.5">
          {ticket.issues.map((issue) => (
            <span
              key={issue}
              className="rounded-full bg-muted px-2.5 py-1 text-[11px] font-semibold text-muted-foreground"
            >
              {issue}
            </span>
          ))}
        </div>
      )}

      <div className="mt-2.5 flex flex-wrap items-center gap-x-4 gap-y-1 text-[11.5px] text-muted-foreground">
        {ticket.devicePassword && (
          <span className="flex items-center gap-1">
            <KeyRound className="h-3.5 w-3.5" />
            رمز: <span dir="ltr" className="font-bold text-foreground">{ticket.devicePassword}</span>
          </span>
        )}
        <span className="flex items-center gap-1">
          <Clock className="h-3.5 w-3.5" />
          {relativeTime(ticket.assignedToName ? ticket.createdAt : ticket.createdAt)}
        </span>
      </div>

      {ticket.technicianNotes && (
        <div className="mt-2 rounded-md border border-border bg-background px-3 py-2 text-[12px] leading-5">
          <span className="font-bold text-muted-foreground">یادداشت پذیرش: </span>
          {ticket.technicianNotes}
        </div>
      )}

      {ticket.status === 'IN_PROGRESS' && (
        <button
          type="button"
          onClick={() => setIsPartFormOpen(true)}
          className="mt-3 flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed border-primary py-2 text-[12.5px] font-bold text-primary hover:bg-accent/40"
        >
          <PackagePlus className="h-4 w-4" />
          درخواست قطعه برای این دستگاه
        </button>
      )}

      <div className="mt-3 border-t border-border pt-3">
        <StatusActions
          ticket={ticket}
          assignedToId={ticket.assignedToId}
          currentUserId={currentUserId}
          permissions={permissions}
          onDone={onChanged}
        />
      </div>

      <PartRequestFormDialog
        open={isPartFormOpen}
        onClose={() => setIsPartFormOpen(false)}
        presetReceptionNumber={ticket.ticketNumber}
        presetDeviceTypeId={ticket.device.deviceTypeId ?? undefined}
        presetBrandId={ticket.device.brandId}
        presetModelId={ticket.device.modelId}
        repairTicketId={ticket.id}
        lockDevice
      />
    </div>
  );
}
