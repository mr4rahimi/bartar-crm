'use client';

import { useEffect, useState } from 'react';
import { CheckCircle2, History, PackageOpen, ShieldCheck, Wrench } from 'lucide-react';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { cn } from '@/shared/lib/cn';
import { useMyRepairs, type MyRepairsTab } from '../hooks/use-my-repairs';
import { MyRepairCard } from './my-repair-card';

type MyRepairsViewProps = { currentUserId: string; permissions: string[] };

const TABS: { value: MyRepairsTab; label: string; icon: typeof PackageOpen; alert?: boolean }[] = [
  { value: 'ASSIGNED', label: 'ارجاع‌شده به من', icon: PackageOpen, alert: true },
  { value: 'IN_PROGRESS', label: 'در دست تعمیر', icon: Wrench },
  { value: 'QUALITY_CHECK', label: 'کنترل کیفیت', icon: ShieldCheck, alert: true },
  { value: 'HANDOVER', label: 'تحویل به پذیرش', icon: CheckCircle2 },
  { value: 'HISTORY', label: 'تاریخچه', icon: History },
];

const EMPTY_TEXT: Record<MyRepairsTab, string> = {
  ASSIGNED: 'دستگاهی به شما ارجاع نشده',
  IN_PROGRESS: 'دستگاهی در دست تعمیر ندارید',
  QUALITY_CHECK: 'دستگاهی در انتظار کنترل کیفیت نیست',
  HANDOVER: 'دستگاهی برای تحویل به پذیرش ندارید',
  HISTORY: 'سابقه‌ای ثبت نشده',
};

export function MyRepairsView({ currentUserId, permissions }: MyRepairsViewProps) {
  const [tab, setTab] = useState<MyRepairsTab>('ASSIGNED');

  // شمارنده‌ی تب‌های فعال همیشه به‌روز است تا تعمیرکار کار معطل‌مانده را ببیند
  const assigned = useMyRepairs('ASSIGNED');
  const inProgress = useMyRepairs('IN_PROGRESS');
  const qualityCheck = useMyRepairs('QUALITY_CHECK');
  const handover = useMyRepairs('HANDOVER');
  const history = useMyRepairs('HISTORY', tab === 'HISTORY');

  const byTab = {
    ASSIGNED: assigned,
    IN_PROGRESS: inProgress,
    QUALITY_CHECK: qualityCheck,
    HANDOVER: handover,
    HISTORY: history,
  } as const;

  const active = byTab[tab];

  const refetchActive = () => {
    assigned.refetch();
    inProgress.refetch();
    qualityCheck.refetch();
    handover.refetch();
    if (tab === 'HISTORY') history.refetch();
  };

  // پس از «تعمیر شد» دستگاه به کنترل کیفیت می‌رود؛ اگر تب فعلی خالی شد و
  // کنترل کیفیت مورد جدید دارد، خودکار همان تب باز می‌شود
  const inProgressCount = inProgress.data?.total ?? 0;
  const qualityCount = qualityCheck.data?.total ?? 0;
  useEffect(() => {
    if (tab === 'IN_PROGRESS' && inProgressCount === 0 && qualityCount > 0) {
      setTab('QUALITY_CHECK');
    }
  }, [tab, inProgressCount, qualityCount]);

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-extrabold">دستگاه‌های من</h1>

      {/* تب‌ها — در موبایل افقی اسکرول می‌شوند */}
      <div className="-mx-4 overflow-x-auto px-4 pb-1 md:mx-0 md:px-0">
        <div className="flex min-w-max gap-2">
          {TABS.map((item) => {
            const Icon = item.icon;
            const isActive = tab === item.value;
            const count = byTab[item.value].data?.total ?? 0;
            return (
              <button
                key={item.value}
                type="button"
                onClick={() => setTab(item.value)}
                className={cn(
                  'flex shrink-0 items-center gap-2 rounded-lg border px-3.5 py-2.5 text-[12.5px] font-bold',
                  isActive
                    ? 'border-primary bg-accent text-accent-foreground'
                    : 'border-border bg-card text-muted-foreground',
                )}
              >
                <Icon className="h-4 w-4" />
                {item.label}
                {count > 0 && item.value !== 'HISTORY' && (
                  <span
                    className={cn(
                      'flex h-5 min-w-5 items-center justify-center rounded-full px-1.5 text-[10.5px] font-bold',
                      item.alert && !isActive
                        ? 'bg-destructive text-destructive-foreground'
                        : 'bg-primary text-primary-foreground',
                    )}
                  >
                    {count.toLocaleString('fa-IR')}
                  </span>
                )}
              </button>
            );
          })}
        </div>
      </div>

      {active.isLoading && (
        <div className="space-y-3">
          {[1, 2, 3].map((key) => (
            <Skeleton key={key} className="h-40 w-full" />
          ))}
        </div>
      )}

      {active.data?.items.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-16">
          <PackageOpen className="h-9 w-9 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">{EMPTY_TEXT[tab]}</p>
        </div>
      )}

      <div className="grid grid-cols-1 gap-3 lg:grid-cols-2">
        {active.data?.items.map((ticket) => (
          <MyRepairCard
            key={ticket.id}
            ticket={ticket}
            currentUserId={currentUserId}
            permissions={permissions}
            onChanged={refetchActive}
          />
        ))}
      </div>
    </div>
  );
}
