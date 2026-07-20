'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Bell, CheckCheck } from 'lucide-react';
import { cn } from '@/shared/lib/cn';
import { useInbox, useMarkRead, useMarkAllRead } from '../hooks/use-notifications';

export function NotificationBell() {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const inbox = useInbox();
  const markRead = useMarkRead();
  const markAllRead = useMarkAllRead();

  const unread = inbox.data?.unread ?? 0;

  const handleItemClick = (item: {
    id: string;
    isRead: boolean;
    entityType: string;
    entityId: string;
  }) => {
    if (!item.isRead) markRead.mutate(item.id);
    setOpen(false);
    if (item.entityType === 'RepairTicket') router.push(`/repairs/${item.entityId}`);
  };

  return (
    <div className="relative">
      <button
        type="button"
        onClick={() => setOpen((current) => !current)}
        className="relative flex h-9 w-9 items-center justify-center rounded-md text-muted-foreground hover:bg-muted"
        aria-label="اعلان‌ها"
      >
        <Bell className="h-5 w-5" />
        {unread > 0 && (
          <span className="absolute -right-0.5 -top-0.5 flex h-4 min-w-4 items-center justify-center rounded-full bg-destructive px-1 text-[9px] font-bold text-destructive-foreground">
            {unread > 9 ? '۹+' : unread.toLocaleString('fa-IR')}
          </span>
        )}
      </button>

      {open && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setOpen(false)} />
          <div className="absolute left-0 z-50 mt-1 w-80 overflow-hidden rounded-lg border border-border bg-card shadow-xl">
            <div className="flex items-center justify-between border-b border-border px-3.5 py-2.5">
              <span className="text-[13px] font-extrabold">اعلان‌ها</span>
              {unread > 0 && (
                <button
                  type="button"
                  onClick={() => markAllRead.mutate()}
                  className="flex items-center gap-1 text-[11px] font-bold text-primary hover:underline"
                >
                  <CheckCheck className="h-3.5 w-3.5" />
                  خواندن همه
                </button>
              )}
            </div>

            <div className="max-h-96 overflow-y-auto">
              {inbox.isLoading && (
                <p className="px-3.5 py-6 text-center text-[12px] text-muted-foreground">
                  در حال بارگذاری…
                </p>
              )}
              {inbox.data?.items.length === 0 && (
                <p className="px-3.5 py-8 text-center text-[12px] text-muted-foreground">
                  اعلانی وجود ندارد
                </p>
              )}
              {inbox.data?.items.map((item) => (
                <button
                  key={item.id}
                  type="button"
                  onClick={() => handleItemClick(item)}
                  className={cn(
                    'block w-full border-b border-border px-3.5 py-2.5 text-right last:border-b-0 hover:bg-muted',
                    !item.isRead && 'bg-accent/40',
                  )}
                >
                  <div className="flex items-center gap-2">
                    {!item.isRead && <span className="h-2 w-2 shrink-0 rounded-full bg-primary" />}
                    <span className="text-[12.5px] font-bold">{item.title}</span>
                    <span className="mr-auto text-[10px] text-muted-foreground">
                      {new Date(item.createdAt).toLocaleDateString('fa-IR')}
                    </span>
                  </div>
                  <p className="mt-0.5 text-[11.5px] leading-5 text-muted-foreground">
                    {item.message}
                  </p>
                </button>
              ))}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
