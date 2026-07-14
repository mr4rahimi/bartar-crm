import type { PartRequestStatus } from '@prisma/client';
import {
  getStatusCounts,
  getPurchasesSince,
  getRecentRequests,
  getNeedsReviewCount,
} from '../repositories/dashboard.repository';

const OPEN_STATUSES: PartRequestStatus[] = [
  'CREATED', 'WAITING_CUSTOMER', 'APPROVED', 'WAITING_PURCHASE', 'PURCHASING',
];

const DAYS_IN_TREND = 14;

export async function getDashboardService() {
  const startOfToday = new Date();
  startOfToday.setHours(0, 0, 0, 0);

  const trendStart = new Date(startOfToday);
  trendStart.setDate(trendStart.getDate() - (DAYS_IN_TREND - 1));

  const [statusCounts, purchases, recentRequests, needsReviewCount] = await Promise.all([
    getStatusCounts(),
    getPurchasesSince(trendStart),
    getRecentRequests(),
    getNeedsReviewCount(),
  ]);

  const countByStatus = Object.fromEntries(
    statusCounts.map((entry) => [entry.status, entry._count._all]),
  ) as Partial<Record<PartRequestStatus, number>>;

  // روند خرید ۱۴ روز اخیر — گروه‌بندی روزانه
  const trend: { date: string; count: number; total: number }[] = [];
  for (let dayIndex = 0; dayIndex < DAYS_IN_TREND; dayIndex++) {
    const day = new Date(trendStart);
    day.setDate(day.getDate() + dayIndex);
    trend.push({ date: day.toISOString().slice(0, 10), count: 0, total: 0 });
  }
  for (const purchase of purchases) {
    const key = new Date(purchase.purchasedAt).toISOString().slice(0, 10);
    const bucket = trend.find((entry) => entry.date === key);
    if (bucket) {
      bucket.count += 1;
      bucket.total += purchase.price;
    }
  }

  const today = trend[trend.length - 1] ?? { date: '', count: 0, total: 0 };

  return {
    stats: {
      openRequests: OPEN_STATUSES.reduce(
        (sum, status) => sum + (countByStatus[status] ?? 0),
        0,
      ),
      waitingPurchase:
        (countByStatus.WAITING_PURCHASE ?? 0) + (countByStatus.PURCHASING ?? 0),
      todayPurchaseCount: today.count,
      todayPurchaseTotal: today.total,
      notFound: countByStatus.NOT_FOUND ?? 0,
      needsReviewCount,
    },
    statusCounts: countByStatus,
    purchaseTrend: trend,
    recentRequests: recentRequests.map((request) => ({
      id: request.id,
      partName: request.part.name,
      receptionNumber: request.receptionNumber,
      status: request.status,
      createdAt: request.createdAt,
    })),
  };
}
