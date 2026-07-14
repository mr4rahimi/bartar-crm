import { prisma } from '@/shared/lib/prisma';

const purchaseInclude = {
  vendor: true,
  buyer: true,
  partRequest: { include: { part: true } },
} as const;

export async function listPurchases({ page, pageSize }: { page: number; pageSize: number }) {
  const [items, total] = await prisma.$transaction([
    prisma.purchase.findMany({
      include: purchaseInclude,
      orderBy: { purchasedAt: 'desc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
    prisma.purchase.count(),
  ]);

  return { items, total };
}

export async function findPurchaseById(purchaseId: string) {
  return prisma.purchase.findUnique({ where: { id: purchaseId }, include: purchaseInclude });
}

export async function createPurchase(data: {
  partRequestId: string;
  vendorId: string;
  price: number;
  description: string | null;
  buyerId: string;
}) {
  return prisma.purchase.create({ data, include: purchaseInclude });
}

export async function markPurchaseReturned(purchaseId: string, reason: string) {
  return prisma.purchase.update({
    where: { id: purchaseId },
    data: { isReturned: true, returnedAt: new Date(), returnReason: reason },
    include: purchaseInclude,
  });
}
