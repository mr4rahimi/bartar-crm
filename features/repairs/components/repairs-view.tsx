'use client';

import { useState } from 'react';
import { Plus, Search, Wrench } from 'lucide-react';
import type { RepairTicketStatus } from '@prisma/client';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Badge } from '@/shared/components/ui/badge';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { cn } from '@/shared/lib/cn';
import { useTickets } from '../hooks/use-tickets';
import { TicketFormDialog } from './ticket-form-dialog';
import {
  TICKET_STATUS_LABELS,
  TICKET_STATUS_VARIANTS,
} from '../constants/ticket-status.constants';

const STATUS_FILTERS: { value: RepairTicketStatus | 'all'; label: string }[] = [
  { value: 'all', label: 'همه' },
  { value: 'OPEN', label: TICKET_STATUS_LABELS.OPEN },
  { value: 'IN_PROGRESS', label: TICKET_STATUS_LABELS.IN_PROGRESS },
  { value: 'DELIVERED', label: TICKET_STATUS_LABELS.DELIVERED },
  { value: 'CLOSED', label: TICKET_STATUS_LABELS.CLOSED },
  { value: 'CANCELLED', label: TICKET_STATUS_LABELS.CANCELLED },
];

export function RepairsView() {
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState<RepairTicketStatus | 'all'>('all');
  const [page, setPage] = useState(1);
  const [isFormOpen, setIsFormOpen] = useState(false);

  const debouncedSearch = useDebouncedValue(search);

  const query = useTickets({
    page,
    search: debouncedSearch || undefined,
    status: status === 'all' ? undefined : status,
  });

  const totalPages = query.data ? Math.max(1, Math.ceil(query.data.total / query.data.pageSize)) : 1;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-extrabold">پذیرش / تعمیرات</h1>
        <Button className="h-10 w-auto px-4 text-[13px]" onClick={() => setIsFormOpen(true)}>
          <Plus className="h-4 w-4" />
          پذیرش جدید
        </Button>
      </div>

      <div className="relative">
        <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          className="pr-9"
          placeholder="جستجوی شماره پذیرش، نام یا موبایل مشتری…"
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
          {[1, 2, 3, 4].map((key) => <Skeleton key={key} className="h-24 w-full" />)}
        </div>
      )}

      {query.data?.items.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12">
          <Wrench className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">تیکتی یافت نشد</p>
          <Button className="h-9 w-auto px-4 text-xs" onClick={() => setIsFormOpen(true)}>
            ثبت اولین پذیرش
          </Button>
        </div>
      )}

      <div className="space-y-2">
        {query.data?.items.map((ticket) => (
          <div key={ticket.id} className="rounded-lg border border-border bg-card p-3.5">
            <div className="flex items-center justify-between">
              <div className="text-[13.5px] font-extrabold">
                #{ticket.ticketNumber}
                <span className="mr-2 font-semibold text-muted-foreground">
                  {ticket.customer.name}
                </span>
              </div>
              <Badge variant={TICKET_STATUS_VARIANTS[ticket.status]}>
                {TICKET_STATUS_LABELS[ticket.status]}
              </Badge>
            </div>
            <div className="mt-1.5 text-[12.5px] text-muted-foreground">
              {ticket.device.brand} {ticket.device.model}
              {ticket.issueDescription && ` — ${ticket.issueDescription}`}
            </div>
            <div className="mt-1.5 flex items-center justify-between text-[11.5px] text-muted-foreground">
              <span>ثبت: {ticket.createdByName}</span>
              <span>{new Date(ticket.createdAt).toLocaleDateString('fa-IR')}</span>
            </div>
          </div>
        ))}
      </div>

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
            صفحه {page} از {totalPages}
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

      <TicketFormDialog open={isFormOpen} onClose={() => setIsFormOpen(false)} />
    </div>
  );
}
