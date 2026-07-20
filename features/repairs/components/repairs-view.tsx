'use client';

import { useState } from 'react';
import Link from 'next/link';
import { FileText, Pencil, Plus, Printer, Search, Trash2, Wrench } from 'lucide-react';
import type { RepairTicketStatus } from '@prisma/client';
import { Input } from '@/shared/components/ui/input';
import { Button } from '@/shared/components/ui/button';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { IconButton } from '@/shared/components/ui/icon-button';
import { ConfirmDialog } from '@/shared/components/ui/confirm-dialog';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { cn } from '@/shared/lib/cn';
import { useTickets, type TicketSortField } from '../hooks/use-tickets';
import { useDeleteTicket } from '../hooks/use-ticket-mutations';
import { TicketTable } from './ticket-table';
import { TicketEditDialog } from './ticket-edit-dialog';
import { TICKET_STATUS_LABELS, TICKET_STATUSES } from '../constants/ticket-status.constants';
import type { TicketDto } from '../types/ticket.types';

const STATUS_FILTERS: { value: RepairTicketStatus | 'all'; label: string }[] = [
  { value: 'all', label: 'همه' },
  ...TICKET_STATUSES.map((value) => ({ value, label: TICKET_STATUS_LABELS[value] })),
];

export function RepairsView({ permissions }: { permissions: string[] }) {
  const { toast } = useToast();
  const deleteTicket = useDeleteTicket();

  const [search, setSearch] = useState('');
  const [status, setStatus] = useState<RepairTicketStatus | 'all'>('all');
  const [page, setPage] = useState(1);
  const [sortBy, setSortBy] = useState<TicketSortField>('createdAt');
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc');
  const [editing, setEditing] = useState<TicketDto | null>(null);
  const [deleting, setDeleting] = useState<TicketDto | null>(null);

  const debouncedSearch = useDebouncedValue(search, 300);

  const query = useTickets({
    page,
    search: debouncedSearch || undefined,
    status: status === 'all' ? undefined : status,
    sortBy,
    sortDir,
  });

  const canEdit = permissions.includes('EDIT_REPAIR');
  const canDelete = permissions.includes('DELETE_REPAIR');

  const pageSize = query.data?.pageSize ?? 20;
  const totalPages = query.data ? Math.max(1, Math.ceil(query.data.total / pageSize)) : 1;

  const handleSort = (field: TicketSortField) => {
    if (sortBy === field) {
      setSortDir((current) => (current === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortBy(field);
      setSortDir('desc');
    }
    setPage(1);
  };

  const renderActions = (ticket: TicketDto) => (
    <>
      <IconButton icon={FileText} label="فاکتور (به‌زودی)" disabled />
      <IconButton
        icon={Printer}
        label="چاپ قبض"
        onClick={() => window.open(`/repairs/${ticket.id}/print`, '_blank')}
      />
      {canEdit && (
        <IconButton icon={Pencil} label="ویرایش" tone="primary" onClick={() => setEditing(ticket)} />
      )}
      {canDelete && (
        <IconButton
          icon={Trash2}
          label="حذف"
          tone="destructive"
          onClick={() => setDeleting(ticket)}
        />
      )}
    </>
  );

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <h1 className="text-xl font-extrabold">قبض‌های پذیرش</h1>
        <div className="flex items-center gap-2">
          {canDelete && (
            <Link
              href="/repairs/trash"
              className="inline-flex h-10 items-center gap-1.5 rounded-md border border-border bg-card px-3.5 text-[12.5px] font-bold text-muted-foreground hover:bg-muted"
            >
              <Trash2 className="h-4 w-4" />
              حذف‌شده‌ها
            </Link>
          )}
          <Link
            href="/repairs/new"
            className="inline-flex h-10 items-center gap-1.5 rounded-md bg-primary px-4 text-[13px] font-bold text-primary-foreground"
          >
            <Plus className="h-4 w-4" />
            قبض پذیرش جدید
          </Link>
        </div>
      </div>

      <div className="relative">
        <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          className="pr-9"
          placeholder="جستجوی زنده: شماره پذیرش، نام مشتری یا شماره همراه…"
          value={search}
          onChange={(event) => { setSearch(event.target.value); setPage(1); }}
        />
      </div>

      <div className="flex flex-wrap gap-2">
        {STATUS_FILTERS.map((chip) => (
          <button
            key={chip.value}
            type="button"
            onClick={() => { setStatus(chip.value); setPage(1); }}
            className={cn(
              'rounded-full border px-3.5 py-1.5 text-xs font-semibold',
              status === chip.value
                ? 'border-primary bg-accent text-accent-foreground'
                : 'border-border bg-card text-muted-foreground',
            )}
          >
            {chip.label}
          </button>
        ))}
      </div>

      {query.isLoading && (
        <div className="space-y-2">
          {[1, 2, 3, 4, 5].map((key) => <Skeleton key={key} className="h-14 w-full" />)}
        </div>
      )}

      {query.data?.items.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12">
          <Wrench className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">قبضی یافت نشد</p>
          <Link
            href="/repairs/new"
            className="inline-flex h-9 items-center rounded-md bg-primary px-4 text-xs font-bold text-primary-foreground"
          >
            ثبت قبض پذیرش
          </Link>
        </div>
      )}

      {query.data && query.data.items.length > 0 && (
        <TicketTable
          items={query.data.items}
          startIndex={(page - 1) * pageSize}
          sortBy={sortBy}
          sortDir={sortDir}
          onSort={handleSort}
          renderActions={renderActions}
        />
      )}

      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-3 text-sm">
          <Button
            variant="outline"
            className="h-9 w-auto px-4 text-xs"
            disabled={page <= 1}
            onClick={() => setPage((current) => current - 1)}
          >
            قبلی
          </Button>
          <span className="font-semibold text-muted-foreground">
            صفحه {page.toLocaleString('fa-IR')} از {totalPages.toLocaleString('fa-IR')}
            {query.data && ` — ${query.data.total.toLocaleString('fa-IR')} قبض`}
          </span>
          <Button
            variant="outline"
            className="h-9 w-auto px-4 text-xs"
            disabled={page >= totalPages}
            onClick={() => setPage((current) => current + 1)}
          >
            بعدی
          </Button>
        </div>
      )}

      <TicketEditDialog ticket={editing} onClose={() => setEditing(null)} />

      <ConfirmDialog
        open={deleting !== null}
        title="حذف قبض پذیرش"
        message={`قبض #${deleting?.ticketNumber} برای «${deleting?.customer.name}» به بخش حذف‌شده‌ها منتقل می‌شود و بعداً قابل بازیابی است.`}
        confirmLabel="حذف"
        isPending={deleteTicket.isPending}
        onClose={() => setDeleting(null)}
        onConfirm={() => {
          if (!deleting) return;
          deleteTicket.mutate(deleting.id, {
            onSuccess: () => { toast('قبض به حذف‌شده‌ها منتقل شد'); setDeleting(null); },
            onError: (error) => toast(error.message, 'error'),
          });
        }}
      />
    </div>
  );
}
