'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Package, Plus, Search } from 'lucide-react';
import type { PartRequestStatus } from '@prisma/client';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { StatusChip } from '@/shared/components/ui/status-chip';
import { PART_REQUEST_STATUS_LABELS } from '@/shared/constants/part-request-status';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { cn } from '@/shared/lib/cn';
import { usePartRequests } from '../hooks/use-part-requests';
import { PartRequestFormDialog } from './part-request-form-dialog';
import { QUALITY_LABELS } from '../constants/state-machine.constants';

const FILTER_STATUSES: (PartRequestStatus | 'all')[] = [
  'all', 'CREATED', 'WAITING_CUSTOMER', 'WAITING_PURCHASE', 'PURCHASING',
  'PURCHASED', 'NOT_FOUND', 'DELIVERED', 'CLOSED',
];

export function PartRequestsView() {
  const [search, setSearch] = useState('');
  const [status, setStatus] = useState<PartRequestStatus | 'all'>('all');
  const [page, setPage] = useState(1);
  const [isFormOpen, setIsFormOpen] = useState(false);

  const debouncedSearch = useDebouncedValue(search);

  const query = usePartRequests({
    page,
    search: debouncedSearch || undefined,
    status: status === 'all' ? undefined : status,
  });

  const totalPages = query.data ? Math.max(1, Math.ceil(query.data.total / query.data.pageSize)) : 1;

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-extrabold">درخواست‌های قطعه</h1>
        <Button className="h-10 w-auto px-4 text-[13px]" onClick={() => setIsFormOpen(true)}>
          <Plus className="h-4 w-4" />
          درخواست جدید
        </Button>
      </div>

      <div className="relative">
        <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          className="pr-9"
          placeholder="جستجوی شماره پذیرش یا نام قطعه…"
          value={search}
          onChange={(event) => { setSearch(event.target.value); setPage(1); }}
        />
      </div>

      <div className="flex gap-2 overflow-x-auto pb-1">
        {FILTER_STATUSES.map((value) => (
          <button
            key={value}
            type="button"
            onClick={() => { setStatus(value); setPage(1); }}
            className={cn(
              'whitespace-nowrap rounded-full border px-3.5 py-1.5 text-xs font-semibold',
              status === value
                ? 'border-primary bg-accent text-accent-foreground'
                : 'border-border bg-card text-muted-foreground',
            )}
          >
            {value === 'all' ? 'همه' : PART_REQUEST_STATUS_LABELS[value]}
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
          <Package className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">درخواستی یافت نشد</p>
          <Button className="h-9 w-auto px-4 text-xs" onClick={() => setIsFormOpen(true)}>
            ثبت اولین درخواست
          </Button>
        </div>
      )}

      <div className="space-y-2">
        {query.data?.items.map((request) => (
          <Link
            key={request.id}
            href={`/part-requests/${request.id}`}
            className="block rounded-lg border border-border bg-card p-3.5 transition-colors hover:border-primary/40"
          >
            <div className="flex items-center justify-between gap-2">
              <div className="text-[13.5px] font-extrabold">
                {request.partName}
                {request.isTest && (
                  <span className="mr-2 text-[11px] font-bold text-muted-foreground">(تست)</span>
                )}
              </div>
              <StatusChip status={request.status} />
            </div>
            <div className="mt-1.5 text-[12.5px] text-muted-foreground">
              پذیرش #{request.receptionNumber} — {QUALITY_LABELS[request.quality]} — {request.quantity} عدد
              {request.announcedPrice !== null &&
                ` — اعلامی: ${request.announcedPrice.toLocaleString('fa-IR')} تومان`}
            </div>
            <div className="mt-1.5 flex items-center justify-between text-[11.5px] text-muted-foreground">
              <span>ثبت: {request.createdByName}</span>
              <span>{new Date(request.createdAt).toLocaleDateString('fa-IR')}</span>
            </div>
          </Link>
        ))}
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-3 text-sm">
          <Button variant="outline" className="h-9 w-auto px-4 text-xs" disabled={page <= 1}
            onClick={() => setPage((current) => current - 1)}>
            قبلی
          </Button>
          <span className="font-semibold text-muted-foreground">صفحه {page} از {totalPages}</span>
          <Button variant="outline" className="h-9 w-auto px-4 text-xs" disabled={page >= totalPages}
            onClick={() => setPage((current) => current + 1)}>
            بعدی
          </Button>
        </div>
      )}

      <PartRequestFormDialog open={isFormOpen} onClose={() => setIsFormOpen(false)} />
    </div>
  );
}
