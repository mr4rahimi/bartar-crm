'use client';

import { ArrowDown, ArrowUp, ChevronsUpDown } from 'lucide-react';
import type { ReactNode } from 'react';
import { cn } from '@/shared/lib/cn';
import type { TicketDto } from '../types/ticket.types';
import type { TicketSortField } from '../hooks/use-tickets';
import { TICKET_STATUS_LABELS, TICKET_STATUS_CLASSES } from '../constants/ticket-status.constants';

const formatDate = (value: Date | string) => new Date(value).toLocaleDateString('fa-IR');
const formatTime = (value: Date | string) =>
  new Date(value).toLocaleTimeString('fa-IR', { hour: '2-digit', minute: '2-digit' });

type Column = { key: string; label: string; sortField?: TicketSortField; className?: string };

const COLUMNS: Column[] = [
  { key: 'row', label: '#', className: 'w-12 text-center' },
  { key: 'date', label: 'تاریخ', sortField: 'createdAt', className: 'w-24' },
  { key: 'time', label: 'ساعت', className: 'w-16' },
  { key: 'customer', label: 'نام و نام خانوادگی', sortField: 'customerName' },
  { key: 'phone', label: 'شماره همراه', className: 'w-32' },
  { key: 'ticketNumber', label: 'شماره پذیرش', sortField: 'ticketNumber', className: 'w-28' },
  { key: 'status', label: 'وضعیت', sortField: 'status', className: 'w-28' },
  { key: 'deviceType', label: 'نوع دستگاه', className: 'w-24' },
  { key: 'brand', label: 'برند', className: 'w-24' },
  { key: 'model', label: 'مدل', className: 'w-32' },
  { key: 'serial', label: 'سریال', className: 'w-28' },
];

export function StatusBadge({ ticket }: { ticket: TicketDto }) {
  return (
    <span
      className={cn(
        'inline-block whitespace-nowrap rounded-full px-2.5 py-1 text-[11px] font-bold',
        TICKET_STATUS_CLASSES[ticket.status],
      )}
    >
      {TICKET_STATUS_LABELS[ticket.status]}
    </span>
  );
}

type TicketTableProps = {
  items: TicketDto[];
  startIndex: number;
  sortBy: TicketSortField;
  sortDir: 'asc' | 'desc';
  onSort: (field: TicketSortField) => void;
  renderActions: (ticket: TicketDto) => ReactNode;
  /** ستون‌های اضافه برای سطل حذف‌شده‌ها */
  showDeletedInfo?: boolean;
};

export function TicketTable({
  items,
  startIndex,
  sortBy,
  sortDir,
  onSort,
  renderActions,
  showDeletedInfo = false,
}: TicketTableProps) {
  const SortIcon = ({ field }: { field?: TicketSortField }) => {
    if (!field) return null;
    if (sortBy !== field) return <ChevronsUpDown className="h-3 w-3 opacity-40" />;
    return sortDir === 'asc' ? <ArrowUp className="h-3 w-3" /> : <ArrowDown className="h-3 w-3" />;
  };

  return (
    <>
      {/* ---------- دسکتاپ ---------- */}
      <div className="hidden overflow-x-auto rounded-lg border border-border bg-card lg:block">
        <table className="w-full text-right">
          <thead>
            <tr className="border-b border-border bg-muted/40">
              {COLUMNS.map((column) => (
                <th
                  key={column.key}
                  className={cn('px-3 py-2.5 text-[11.5px] font-extrabold', column.className)}
                >
                  {column.sortField ? (
                    <button
                      type="button"
                      onClick={() => onSort(column.sortField!)}
                      className="inline-flex items-center gap-1 hover:text-primary"
                    >
                      {column.label}
                      <SortIcon field={column.sortField} />
                    </button>
                  ) : (
                    column.label
                  )}
                </th>
              ))}
              {showDeletedInfo && (
                <th className="w-32 px-3 py-2.5 text-[11.5px] font-extrabold">حذف توسط</th>
              )}
              <th className="w-36 px-3 py-2.5 text-center text-[11.5px] font-extrabold">عملیات</th>
            </tr>
          </thead>
          <tbody>
            {items.map((ticket, index) => (
              <tr
                key={ticket.id}
                className="border-b border-border last:border-b-0 hover:bg-muted/30"
              >
                <td className="px-3 py-2.5 text-center text-[12px] font-bold text-muted-foreground">
                  {(startIndex + index + 1).toLocaleString('fa-IR')}
                </td>
                <td className="whitespace-nowrap px-3 py-2.5 text-[12px]">
                  {formatDate(ticket.createdAt)}
                </td>
                <td className="whitespace-nowrap px-3 py-2.5 text-[12px] text-muted-foreground">
                  {formatTime(ticket.createdAt)}
                </td>
                <td className="px-3 py-2.5 text-[12.5px] font-bold">{ticket.customer.name}</td>
                <td dir="ltr" className="px-3 py-2.5 text-right text-[12px]">
                  {ticket.customer.phone}
                </td>
                <td className="px-3 py-2.5 text-[12.5px] font-extrabold text-primary">
                  {ticket.ticketNumber}
                </td>
                <td className="px-3 py-2.5">
                  <StatusBadge ticket={ticket} />
                </td>
                <td className="px-3 py-2.5 text-[12px]">{ticket.device.deviceType ?? '—'}</td>
                <td className="px-3 py-2.5 text-[12px]">{ticket.device.brand}</td>
                <td className="px-3 py-2.5 text-[12px]">{ticket.device.model}</td>
                <td dir="ltr" className="px-3 py-2.5 text-right text-[11.5px] text-muted-foreground">
                  {ticket.device.serial || '—'}
                </td>
                {showDeletedInfo && (
                  <td className="px-3 py-2.5 text-[11.5px]">
                    <div className="font-bold">{ticket.deletedByName ?? '—'}</div>
                    {ticket.deletedAt && (
                      <div className="text-muted-foreground">{formatDate(ticket.deletedAt)}</div>
                    )}
                  </td>
                )}
                <td className="px-3 py-2.5">
                  <div className="flex items-center justify-center gap-0.5">
                    {renderActions(ticket)}
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* ---------- موبایل ---------- */}
      <div className="space-y-2 lg:hidden">
        {items.map((ticket, index) => (
          <div key={ticket.id} className="rounded-lg border border-border bg-card p-3.5">
            <div className="flex items-start justify-between gap-2">
              <div>
                <div className="flex items-center gap-2">
                  <span className="text-[11px] font-bold text-muted-foreground">
                    {(startIndex + index + 1).toLocaleString('fa-IR')}
                  </span>
                  <span className="text-[13.5px] font-extrabold text-primary">
                    #{ticket.ticketNumber}
                  </span>
                </div>
                <div className="mt-1 text-[13px] font-bold">{ticket.customer.name}</div>
                <div dir="ltr" className="text-right text-[12px] text-muted-foreground">
                  {ticket.customer.phone}
                </div>
              </div>
              <StatusBadge ticket={ticket} />
            </div>

            <div className="mt-2 text-[12px] text-muted-foreground">
              {[ticket.device.deviceType, ticket.device.brand, ticket.device.model]
                .filter(Boolean)
                .join(' ')}
              {ticket.device.serial && ` — ${ticket.device.serial}`}
            </div>

            <div className="mt-2 flex items-center justify-between border-t border-border pt-2">
              <span className="text-[11px] text-muted-foreground">
                {formatDate(ticket.createdAt)} — {formatTime(ticket.createdAt)}
                {showDeletedInfo && ticket.deletedByName && ` — حذف: ${ticket.deletedByName}`}
              </span>
              <div className="flex items-center gap-0.5">{renderActions(ticket)}</div>
            </div>
          </div>
        ))}
      </div>
    </>
  );
}
