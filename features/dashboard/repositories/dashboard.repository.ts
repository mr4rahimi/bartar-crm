import { prisma } from '@/shared/lib/prisma';

export async function getStatusCounts() {
  return prisma.partRequest.groupBy({
    by: ['status'],
    where: { deletedAt: null },
    _count: { _all: true },
  });
}

export async function getPurchasesSince(since: Date) {
  return prisma.purchase.findMany({
    where: { purchasedAt: { gte: since }, isReturned: false },
    select: { price: true, purchasedAt: true },
  });
}

export async function getRecentRequests(take = 5) {
  return prisma.partRequest.findMany({
    where: { deletedAt: null },
    include: { part: true },
    orderBy: { createdAt: 'desc' },
    take,
  });
}

export async function getNeedsReviewCount() {
  return prisma.partPrice.count({ where: { needsReview: true } });
}
