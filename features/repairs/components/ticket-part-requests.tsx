'use client';

import { useRouter } from 'next/navigation';
import { PackageOpen } from 'lucide-react';
import { cn } from '@/shared/lib/cn';
import {
  PART_REQUEST_STATUS_LABELS,
  PART_REQUEST_STATUS_FAMILY,
  type StatusFamily,
} from '@/shared/constants/part-request-status';
import { useTicketPartRequests } from '@/features/part-requests/hooks/use-ticket-part-requests';

const FAMILY_CLASSES: Record<StatusFamily, string> = {
  gray: 'bg-muted text-muted-foreground',
  yellow: 'bg-[#fef9e7] text-[#92730c] dark:bg-[#332b0f] dark:text-[#fbbf24]',
  blue: 'bg-[#eaf1fe] text-[#1d4ed8] dark:bg-[#122236] dark:text-[#60a5fa]',
  green: 'bg-[#eafaf0] text-[#15803d] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
  red: 'bg-[#fdecec] text-[#b91c1c] dark:bg-[#341313] dark:text-[#f87171]',
  orange: 'bg-[#fdf0e6] text-[#c2570c] dark:bg-[#33210f] dark:text-[#fb923c]',
  dark: 'bg-foreground/10 text-foreground',
};

export function TicketPartRequests({ ticketId }: { ticketId: string }) {
  const router = useRouter();
  const query = useTicketPartRequests(ticketId);

  if (query.isLoading) {
    return <p className="py-3 text-center text-[12px] text-muted-foreground">در حال بارگذاری…</p>;
  }

  if (!query.data || query.data.length === 0) {
    return (
      <div className="flex flex-col items-center gap-1.5 py-6 text-muted-foreground">
        <PackageOpen className="h-6 w-6" />
        <p className="text-[12px]">قطعه‌ای برای این دستگاه درخواست نشده</p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {query.data.map((item) => (
        <button
          key={item.id}
          type="button"
          onClick={() => router.push('/part-requests/' + item.id)}
          className="flex w-full items-center justify-between gap-2 rounded-md border border-border bg-background px-3 py-2 text-right hover:bg-muted"
        >
          <div>
            <div className="text-[12.5px] font-bold">
              {item.partName}
              {item.quantity > 1 && (
                <span className="mr-1 text-muted-foreground">×{item.quantity.toLocaleString('fa-IR')}</span>
              )}
            </div>
            {item.announcedPrice != null && (
              <div className="text-[11px] text-muted-foreground">
                {item.announcedPrice.toLocaleString('fa-IR')} تومان
              </div>
            )}
          </div>
          <span
            className={cn(
              'shrink-0 rounded-full px-2.5 py-1 text-[10.5px] font-bold',
              FAMILY_CLASSES[PART_REQUEST_STATUS_FAMILY[item.status]],
            )}
          >
            {PART_REQUEST_STATUS_LABELS[item.status]}
          </span>
        </button>
      ))}
    </div>
  );
}
