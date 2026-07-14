import { prisma } from '@/shared/lib/prisma';
import type { PartQuality, PriceType } from '@prisma/client';

export async function findPartPrice(modelId: string, partId: string, quality: PartQuality) {
  return prisma.partPrice.findUnique({
    where: { modelId_partId_quality: { modelId, partId, quality } },
  });
}

export async function upsertPartPrice(params: {
  modelId: string;
  partId: string;
  quality: PartQuality;
  buyPrice: number;
  sellPrice: number | null;
  needsReview: boolean;
}) {
  const { modelId, partId, quality, buyPrice, sellPrice, needsReview } = params;

  return prisma.partPrice.upsert({
    where: { modelId_partId_quality: { modelId, partId, quality } },
    update: {
      buyPrice,
      ...(sellPrice !== null && { sellPrice }),
      needsReview,
    },
    create: { modelId, partId, quality, buyPrice, sellPrice, needsReview },
  });
}

export async function createPriceHistory(params: {
  partId: string;
  modelId: string | null;
  quality: PartQuality | null;
  purchaseId: string | null;
  type: PriceType;
  price: number;
}) {
  return prisma.priceHistory.create({ data: params });
}
