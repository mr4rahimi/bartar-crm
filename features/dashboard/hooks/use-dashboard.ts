'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { PartRequestStatus } from '@prisma/client';

export type DashboardData = {
  stats: {
    openRequests: number;
    waitingPurchase: number;
    todayPurchaseCount: number;
    todayPurchaseTotal: number;
    notFound: number;
    needsReviewCount: number;
  };
  statusCounts: Partial<Record<PartRequestStatus, number>>;
  purchaseTrend: { date: string; count: number; total: number }[];
  recentRequests: {
    id: string;
    partName: string;
    receptionNumber: string;
    status: PartRequestStatus;
    createdAt: string;
  }[];
};

export function useDashboard() {
  return useQuery({
    queryKey: ['dashboard'],
    queryFn: () => apiFetch<DashboardData>('/api/v1/dashboard'),
    refetchInterval: 60_000,
  });
}
