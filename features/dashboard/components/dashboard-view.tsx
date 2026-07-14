'use client';

import Link from 'next/link';
import {
  Package, ShoppingCart, CircleCheck, TriangleAlert, type LucideIcon,
} from 'lucide-react';
import {
  ResponsiveContainer, AreaChart, Area, BarChart, Bar, XAxis, YAxis,
  Tooltip, CartesianGrid, Cell,
} from 'recharts';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { StatusChip } from '@/shared/components/ui/status-chip';
import {
  PART_REQUEST_STATUS_LABELS,
  PART_REQUEST_STATUS_FAMILY,
  type StatusFamily,
} from '@/shared/constants/part-request-status';
import { useDashboard } from '../hooks/use-dashboard';
import type { PartRequestStatus } from '@prisma/client';

const FAMILY_HEX: Record<StatusFamily, string> = {
  gray: '#71717a', yellow: '#eab308', blue: '#3b82f6', green: '#22c55e',
  red: '#ef4444', orange: '#f97316', dark: '#52525b',
};

function StatCard({
  icon: Icon, label, value, sub, tone,
}: {
  icon: LucideIcon; label: string; value: string; sub?: string; tone: string;
}) {
  return (
    <div className="rounded-lg border border-border bg-card p-4">
      <div className="flex items-center justify-between">
        <span className="text-[11.5px] font-bold text-muted-foreground">{label}</span>
        <Icon className="h-4 w-4" style={{ color: tone }} />
      </div>
      <div className="mt-2 text-2xl font-extrabold">{value}</div>
      {sub && <div className="mt-0.5 text-[11px] text-muted-foreground">{sub}</div>}
    </div>
  );
}

export function DashboardView() {
  const query = useDashboard();

  if (query.isLoading || !query.data) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-8 w-40" />
        <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
          {[1, 2, 3, 4].map((key) => <Skeleton key={key} className="h-28 w-full" />)}
        </div>
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  const { stats, statusCounts, purchaseTrend, recentRequests } = query.data;

  const statusChartData = (Object.keys(PART_REQUEST_STATUS_LABELS) as PartRequestStatus[])
    .map((status) => ({
      status,
      name: PART_REQUEST_STATUS_LABELS[status],
      count: statusCounts[status] ?? 0,
    }))
    .filter((entry) => entry.count > 0);

  const trendData = purchaseTrend.map((entry) => ({
    ...entry,
    label: new Date(entry.date).toLocaleDateString('fa-IR', { month: 'numeric', day: 'numeric' }),
    million: Math.round(entry.total / 100_000) / 10,
  }));

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-extrabold">داشبورد</h1>

      {stats.needsReviewCount > 0 && (
        <Link
          href="/pricing"
          className="flex items-center gap-2 rounded-lg border border-[#f0d878] bg-[#fef9e7] p-3.5 text-[13px] font-extrabold text-[#92730c] dark:border-[#4d4014] dark:bg-[#332b0f] dark:text-[#fbbf24]"
        >
          <TriangleAlert className="h-4 w-4" />
          {stats.needsReviewCount} قیمت نیاز به بازبینی دارد — برای ویرایش کلیک کنید
        </Link>
      )}

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <StatCard icon={Package} label="درخواست‌های باز" value={stats.openRequests.toLocaleString('fa-IR')} tone="#3b82f6" />
        <StatCard icon={ShoppingCart} label="در صف / در حال خرید" value={stats.waitingPurchase.toLocaleString('fa-IR')} tone="#eab308" />
        <StatCard
          icon={CircleCheck}
          label="خریدهای امروز"
          value={stats.todayPurchaseCount.toLocaleString('fa-IR')}
          sub={stats.todayPurchaseTotal > 0 ? `${stats.todayPurchaseTotal.toLocaleString('fa-IR')} تومان` : undefined}
          tone="#22c55e"
        />
        <StatCard icon={TriangleAlert} label="عدم موجودی" value={stats.notFound.toLocaleString('fa-IR')} tone="#ef4444" />
      </div>

      <div className="grid grid-cols-1 gap-3 lg:grid-cols-2">
        <div className="rounded-lg border border-border bg-card p-4">
          <h2 className="mb-3 text-sm font-extrabold">مبلغ خرید ۱۴ روز اخیر (میلیون تومان)</h2>
          <ResponsiveContainer width="100%" height={220}>
            <AreaChart data={trendData} margin={{ top: 5, right: 5, left: 5, bottom: 0 }}>
              <defs>
                <linearGradient id="trendFill" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#22c55e" stopOpacity={0.35} />
                  <stop offset="100%" stopColor="#22c55e" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke="currentColor" opacity={0.1} />
              <XAxis dataKey="label" tick={{ fontSize: 10, fill: 'currentColor' }} tickLine={false} axisLine={false} />
              <YAxis tick={{ fontSize: 10, fill: 'currentColor' }} tickLine={false} axisLine={false} width={30} />
              <Tooltip
                contentStyle={{ background: 'hsl(var(--card))', border: '1px solid hsl(var(--border))', borderRadius: 10, fontSize: 12, fontFamily: 'inherit' }}
                formatter={(value: number, key) =>
                  key === 'million' ? [`${value.toLocaleString('fa-IR')} میلیون`, 'مبلغ'] : [value, key]
                }
                labelFormatter={(label) => `تاریخ: ${label}`}
              />
              <Area type="monotone" dataKey="million" stroke="#22c55e" strokeWidth={2} fill="url(#trendFill)" />
            </AreaChart>
          </ResponsiveContainer>
        </div>

        <div className="rounded-lg border border-border bg-card p-4">
          <h2 className="mb-3 text-sm font-extrabold">درخواست‌ها بر اساس وضعیت</h2>
          {statusChartData.length === 0 ? (
            <p className="py-16 text-center text-sm text-muted-foreground">درخواستی ثبت نشده</p>
          ) : (
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={statusChartData} margin={{ top: 5, right: 5, left: 5, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="currentColor" opacity={0.1} />
                <XAxis dataKey="name" tick={{ fontSize: 9, fill: 'currentColor' }} tickLine={false} axisLine={false} interval={0} angle={-20} height={45} />
                <YAxis allowDecimals={false} tick={{ fontSize: 10, fill: 'currentColor' }} tickLine={false} axisLine={false} width={25} />
                <Tooltip
                  cursor={{ fill: 'transparent' }}
                  contentStyle={{ background: 'hsl(var(--card))', border: '1px solid hsl(var(--border))', borderRadius: 10, fontSize: 12, fontFamily: 'inherit' }}
                  formatter={(value: number) => [value.toLocaleString('fa-IR'), 'تعداد']}
                />
                <Bar dataKey="count" radius={[6, 6, 0, 0]}>
                  {statusChartData.map((entry) => (
                    <Cell key={entry.status} fill={FAMILY_HEX[PART_REQUEST_STATUS_FAMILY[entry.status]]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          )}
        </div>
      </div>

      <div className="rounded-lg border border-border bg-card p-4">
        <h2 className="mb-3 text-sm font-extrabold">آخرین درخواست‌ها</h2>
        {recentRequests.length === 0 && (
          <p className="py-6 text-center text-sm text-muted-foreground">درخواستی ثبت نشده</p>
        )}
        <div className="space-y-1.5">
          {recentRequests.map((request) => (
            <Link
              key={request.id}
              href={`/part-requests/${request.id}`}
              className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-2.5 hover:border-primary/40"
            >
              <div>
                <span className="text-[13px] font-bold">{request.partName}</span>
                <span className="mr-2 text-[11.5px] text-muted-foreground">
                  #{request.receptionNumber}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <span className="text-[10.5px] text-muted-foreground">
                  {new Date(request.createdAt).toLocaleDateString('fa-IR')}
                </span>
                <StatusChip status={request.status} />
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}
