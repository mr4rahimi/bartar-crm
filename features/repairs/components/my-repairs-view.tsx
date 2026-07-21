'use client';

import { useState } from 'react';
import { PackageOpen, Wrench } from 'lucide-react';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { cn } from '@/shared/lib/cn';
import { useMyRepairs } from '../hooks/use-my-repairs';
import { MyRepairCard } from './my-repair-card';

type Tab = 'ASSIGNED' | 'IN_PROGRESS';

type MyRepairsViewProps = { currentUserId: string; permissions: string[] };

export function MyRepairsView({ currentUserId, permissions }: MyRepairsViewProps) {
  const [tab, setTab] = useState<Tab>('ASSIGNED');

  const assigned = useMyRepairs('ASSIGNED');
  const inProgress = useMyRepairs('IN_PROGRESS');

  const active = tab === 'ASSIGNED' ? assigned : inProgress;
  const assignedCount = assigned.data?.total ?? 0;

  const TABS: { value: Tab; label: string; icon: typeof PackageOpen }[] = [
    { value: 'ASSIGNED', label: 'ارجاع‌شده به من', icon: PackageOpen },
    { value: 'IN_PROGRESS', label: 'در دست تعمیر', icon: Wrench },
  ];

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-extrabold">دستگاه‌های من</h1>

      <div className="flex gap-2">
        {TABS.map((item) => {
          const Icon = item.icon;
          const isActive = tab === item.value;
          const badge = item.value === 'ASSIGNED' ? assignedCount : inProgress.data?.total ?? 0;
          return (
            <button
              key={item.value}
              type="button"
              onClick={() => setTab(item.value)}
              className={cn(
                'flex flex-1 items-center justify-center gap-2 rounded-lg border px-4 py-3 text-[13px] font-bold',
                isActive
                  ? 'border-primary bg-accent text-accent-foreground'
                  : 'border-border bg-card text-muted-foreground',
              )}
            >
              <Icon className="h-4 w-4" />
              {item.label}
              {badge > 0 && (
                <span
                  className={cn(
                    'flex h-5 min-w-5 items-center justify-center rounded-full px-1.5 text-[10.5px] font-bold',
                    item.value === 'ASSIGNED' && !isActive
                      ? 'bg-destructive text-destructive-foreground'
                      : 'bg-primary text-primary-foreground',
                  )}
                >
                  {badge.toLocaleString('fa-IR')}
                </span>
              )}
            </button>
          );
        })}
      </div>

      {active.isLoading && (
        <div className="space-y-3">
          {[1, 2, 3].map((key) => <Skeleton key={key} className="h-40 w-full" />)}
        </div>
      )}

      {active.data?.items.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-16">
          <PackageOpen className="h-9 w-9 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">
            {tab === 'ASSIGNED' ? 'دستگاهی به شما ارجاع نشده' : 'دستگاهی در دست تعمیر ندارید'}
          </p>
        </div>
      )}

      <div className="grid grid-cols-1 gap-3 lg:grid-cols-2">
        {active.data?.items.map((ticket) => (
          <MyRepairCard
            key={ticket.id}
            ticket={ticket}
            currentUserId={currentUserId}
            permissions={permissions}
            onChanged={() => {
              assigned.refetch();
              inProgress.refetch();
            }}
          />
        ))}
      </div>
    </div>
  );
}
