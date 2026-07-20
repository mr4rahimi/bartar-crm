'use client';

import { useRouter } from 'next/navigation';
import { ArrowRight, Printer } from 'lucide-react';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { StatusBadge } from './ticket-table';
import { StatusActions } from './status-actions';
import { StatusTimeline } from './status-timeline';
import { useTicket } from '../hooks/use-tickets';

const formatDate = (value: Date | string | null) =>
  value ? new Date(value).toLocaleDateString('fa-IR') : '—';
const formatDateTime = (value: Date | string | null) =>
  value ? new Date(value).toLocaleString('fa-IR') : '—';
const formatPrice = (value: number | null) =>
  value ? `${value.toLocaleString('fa-IR')} تومان` : '—';

type DetailProps = { ticketId: string; currentUserId: string; permissions: string[] };

export function TicketDetailView({ ticketId, currentUserId, permissions }: DetailProps) {
  const router = useRouter();
  const query = useTicket(ticketId);

  if (query.isLoading) return <Skeleton className="h-96 w-full" />;
  const ticket = query.data;
  if (!ticket) return null;

  // نگهدارنده‌ی فعلی: تا تحویل‌نگرفتن، دست ارجاع‌دهنده/پذیرش است
  const holder =
    ticket.status === 'IN_PROGRESS'
      ? ticket.assignedToName
      : ticket.status === 'ASSIGNED'
        ? `${ticket.assignedToName} (در انتظار تحویل)`
        : 'پذیرش';

  const deviceTitle = [ticket.device.deviceType, ticket.device.brand, ticket.device.model]
    .filter(Boolean)
    .join(' ');

  const fields = [
    { label: 'مشتری', value: ticket.customer.name },
    { label: 'شماره همراه', value: ticket.customer.phone, ltr: true },
    { label: 'دستگاه', value: deviceTitle },
    { label: 'سریال', value: ticket.device.serial || '—', ltr: true },
    { label: 'تعمیرکار فعلی', value: ticket.assignedToName ?? '—' },
    { label: 'دستگاه دست', value: holder },
    { label: 'هزینه تقریبی', value: formatPrice(ticket.estimatedCost) },
    { label: 'موعد تحویل', value: formatDate(ticket.estimatedDeliveryAt) },
    { label: 'تاریخ پذیرش', value: formatDateTime(ticket.createdAt) },
    { label: 'پذیرش‌گر', value: ticket.createdByName },
  ];

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => router.push('/repairs')}
          className="rounded-md p-1.5 text-muted-foreground hover:bg-muted"
          aria-label="بازگشت"
        >
          <ArrowRight className="h-5 w-5" />
        </button>
        <h1 className="flex-1 text-lg font-extrabold">
          قبض پذیرش #{ticket.ticketNumber}
        </h1>
        <button
          type="button"
          onClick={() => window.open(`/repairs/${ticket.id}/print`, '_blank')}
          className="rounded-md border border-border p-1.5 text-muted-foreground hover:bg-muted"
          aria-label="چاپ"
        >
          <Printer className="h-4 w-4" />
        </button>
        <StatusBadge ticket={ticket} />
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <div className="space-y-4 lg:col-span-2">
          <div className="grid grid-cols-2 gap-x-4 gap-y-3 rounded-lg border border-border bg-card p-4">
            {fields.map((field) => (
              <div key={field.label}>
                <div className="text-[11px] font-bold text-muted-foreground">{field.label}</div>
                <div
                  className="mt-0.5 text-[13px] font-semibold"
                  dir={field.ltr ? 'ltr' : undefined}
                  style={field.ltr ? { textAlign: 'right' } : undefined}
                >
                  {field.value}
                </div>
              </div>
            ))}
          </div>

          {(ticket.issues.length > 0 || ticket.accessories.length > 0) && (
            <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div className="rounded-lg border border-border bg-card p-4">
                <div className="mb-2 text-[12px] font-extrabold">ایرادات</div>
                <div className="text-[12.5px] leading-6 text-muted-foreground">
                  {ticket.issues.length > 0 ? ticket.issues.join('، ') : '—'}
                </div>
              </div>
              <div className="rounded-lg border border-border bg-card p-4">
                <div className="mb-2 text-[12px] font-extrabold">متعلقات</div>
                <div className="text-[12.5px] leading-6 text-muted-foreground">
                  {ticket.accessories.length > 0 ? ticket.accessories.join('، ') : '—'}
                </div>
              </div>
            </div>
          )}

          {(ticket.technicianNotes || ticket.customerNotes) && (
            <div className="space-y-2 rounded-lg border border-border bg-card p-4">
              {ticket.technicianNotes && (
                <div>
                  <div className="text-[11px] font-bold text-muted-foreground">توضیحات تعمیرکار</div>
                  <div className="mt-0.5 text-[12.5px]">{ticket.technicianNotes}</div>
                </div>
              )}
              {ticket.customerNotes && (
                <div>
                  <div className="text-[11px] font-bold text-muted-foreground">توضیحات مشتری</div>
                  <div className="mt-0.5 text-[12.5px]">{ticket.customerNotes}</div>
                </div>
              )}
            </div>
          )}
        </div>

        <div className="space-y-4">
          <div className="rounded-lg border border-border bg-card p-4">
            <h2 className="mb-3 text-sm font-extrabold">اقدام‌ها</h2>
            <StatusActions
              ticket={ticket}
              assignedToId={ticket.assignedToId}
              currentUserId={currentUserId}
              permissions={permissions}
              onDone={() => query.refetch()}
            />
          </div>

          <div className="rounded-lg border border-border bg-card p-4">
            <h2 className="mb-3 text-sm font-extrabold">مراحل</h2>
            <StatusTimeline ticketId={ticket.id} />
          </div>
        </div>
      </div>
    </div>
  );
}
