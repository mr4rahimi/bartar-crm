'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowRight, Printer, RotateCcw, Search, Trash2 } from 'lucide-react';
import { Input } from '@/shared/components/ui/input';
import { Button } from '@/shared/components/ui/button';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { IconButton } from '@/shared/components/ui/icon-button';
import { ConfirmDialog } from '@/shared/components/ui/confirm-dialog';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { useTickets, type TicketSortField } from '../hooks/use-tickets';
import { useRestoreTicket } from '../hooks/use-ticket-mutations';
import { TicketTable } from './ticket-table';
import type { TicketDto } from '../types/ticket.types';

export function TrashView() {
  const router = useRouter();
  const { toast } = useToast();
  const restoreTicket = useRestoreTicket();

  const [search, setSearch] = useState('');
  const [page, setPage] = useState(1);
  const [sortBy, setSortBy] = useState<TicketSortField>('createdAt');
  const [sortDir, setSortDir] = useState<'asc' | 'desc'>('desc');
  const [restoring, setRestoring] = useState<TicketDto | null>(null);

  const debouncedSearch = useDebouncedValue(search, 300);

  const query = useTickets({
    page,
    search: debouncedSearch || undefined,
    sortBy,
    sortDir,
    deleted: true,
  });

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
        <h1 className="flex-1 text-xl font-extrabold">قبض‌های حذف‌شده</h1>
      </div>

      <div className="relative">
        <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          className="pr-9"
          placeholder="جستجو در حذف‌شده‌ها…"
          value={search}
          onChange={(event) => { setSearch(event.target.value); setPage(1); }}
        />
      </div>

      {query.isLoading && (
        <div className="space-y-2">
          {[1, 2, 3].map((key) => <Skeleton key={key} className="h-14 w-full" />)}
        </div>
      )}

      {query.data?.items.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12">
          <Trash2 className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">قبض حذف‌شده‌ای وجود ندارد</p>
        </div>
      )}

      {query.data && query.data.items.length > 0 && (
        <TicketTable
          items={query.data.items}
          startIndex={(page - 1) * pageSize}
          sortBy={sortBy}
          sortDir={sortDir}
          onSort={handleSort}
          showDeletedInfo
          renderActions={(ticket) => (
            <>
              <IconButton
                icon={Printer}
                label="مشاهده قبض"
                onClick={() => window.open(`/repairs/${ticket.id}/print`, '_blank')}
              />
              <IconButton
                icon={RotateCcw}
                label="بازیابی"
                tone="primary"
                onClick={() => setRestoring(ticket)}
              />
            </>
          )}
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

      <ConfirmDialog
        open={restoring !== null}
        title="بازیابی قبض"
        message={`قبض #${restoring?.ticketNumber} به فهرست اصلی بازگردانده می‌شود.`}
        confirmLabel="بازیابی"
        tone="default"
        isPending={restoreTicket.isPending}
        onClose={() => setRestoring(null)}
        onConfirm={() => {
          if (!restoring) return;
          restoreTicket.mutate(restoring.id, {
            onSuccess: () => { toast('قبض بازیابی شد'); setRestoring(null); },
            onError: (error) => toast(error.message, 'error'),
          });
        }}
      />
    </div>
  );
}
