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

export async function listPricesByModel(modelId: string) {
  return prisma.partPrice.findMany({
    where: { modelId },
    include: { part: true },
    orderBy: { part: { name: 'asc' } },
  });
}

export async function listNeedsReview() {
  return prisma.partPrice.findMany({
    where: { needsReview: true },
    include: { part: true, model: { include: { brand: true } } },
    orderBy: { updatedAt: 'desc' },
  });
}

/** ویرایش دستی ادمین — پرچم بازبینی پاک می‌شود */
export async function setPartPriceManual(params: {
  modelId: string;
  partId: string;
  quality: PartQuality;
  buyPrice?: number | null;
  sellPrice?: number | null;
  notes?: string | null;
}) {
  const { modelId, partId, quality, buyPrice, sellPrice, notes } = params;

  return prisma.partPrice.upsert({
    where: { modelId_partId_quality: { modelId, partId, quality } },
    update: {
      ...(buyPrice !== undefined && { buyPrice }),
      ...(sellPrice !== undefined && { sellPrice }),
      ...(notes !== undefined && { notes }),
      needsReview: false,
    },
    create: {
      modelId,
      partId,
      quality,
      buyPrice: buyPrice ?? null,
      sellPrice: sellPrice ?? null,
      notes: notes ?? null,
      needsReview: false,
    },
  });
}

export async function listPriceHistory(modelId: string, partId: string) {
  return prisma.priceHistory.findMany({
    where: { modelId, partId },
    orderBy: { recordedAt: 'desc' },
    take: 50,
  });
}

export async function listPartsForTaxonomy() {
  return prisma.part.findMany({ where: { deletedAt: null }, orderBy: { name: 'asc' } });
}

export type PriceRowFilters = {
  search?: string;
  deviceTypeId?: string;
  brandId?: string;
  partId?: string;
};

/** ردیف‌های قیمت برای لیست تخت (نمایش مثل price-next) — حجم فاز ۱ اجازه‌ی take بالا می‌دهد */
export async function listPriceRows({ search, deviceTypeId, brandId, partId }: PriceRowFilters) {
  return prisma.partPrice.findMany({
    where: {
      ...(partId && { partId }),
      model: {
        ...(brandId && { brandId }),
        ...(deviceTypeId && { deviceTypeId }),
      },
      ...(search && {
        OR: [
          { model: { name: { contains: search, mode: 'insensitive' } } },
          { model: { brand: { name: { contains: search, mode: 'insensitive' } } } },
          { part: { name: { contains: search, mode: 'insensitive' } } },
        ],
      }),
    },
    include: { part: true, model: { include: { brand: true, deviceType: true } } },
    orderBy: { updatedAt: 'desc' },
    take: 900,
  });
}
