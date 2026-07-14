import type { PartQuality } from '@prisma/client';
import {
  findPartPrice,
  upsertPartPrice,
  createPriceHistory,
} from '../repositories/part-price.repository';
import { roundDownTo } from '../utils/money.utils';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

const DEFAULT_MARKUP = 1.3; // بدون سابقه‌ی خرید: +۳۰٪ + پرچم بازبینی (تصمیم کارفرما 2026/07)

export type AutoPricingResult = {
  newSellPrice: number | null;
  needsReview: boolean;
};

/**
 * قانون Auto-Pricing — docs/15-pricing-integration.md:
 * - همیشه PriceHistory از نوع BUY ثبت می‌شود (Price History Rules)
 * - با اتصال به مدل: buyPrice جایگزین و sellPrice با نسبت قبلی (یا ۱.۳ + needsReview) محاسبه می‌شود
 */
export async function applyPurchasePricing(params: {
  partId: string;
  modelId: string | null;
  quality: PartQuality;
  buyPrice: number;
  purchaseId: string;
  context: ActorContext;
}): Promise<AutoPricingResult> {
  const { partId, modelId, quality, buyPrice, purchaseId, context } = params;

  await createPriceHistory({
    partId,
    modelId,
    quality,
    purchaseId,
    type: 'BUY',
    price: buyPrice,
  });

  if (!modelId) {
    // درخواست بدون اتصال به تاکسونومی — قیمت‌گذاری خودکار انجام نمی‌شود
    return { newSellPrice: null, needsReview: false };
  }

  const existing = await findPartPrice(modelId, partId, quality);

  let newSellPrice: number;
  let needsReview: boolean;

  if (existing?.buyPrice && existing.sellPrice) {
    // حفظ نسبت قبلی فروش/خرید
    newSellPrice = roundDownTo(buyPrice * (existing.sellPrice / existing.buyPrice));
    needsReview = false;
  } else {
    newSellPrice = roundDownTo(buyPrice * DEFAULT_MARKUP);
    needsReview = true;
  }

  await upsertPartPrice({ modelId, partId, quality, buyPrice, sellPrice: newSellPrice, needsReview });

  await createPriceHistory({
    partId,
    modelId,
    quality,
    purchaseId,
    type: 'SELL',
    price: newSellPrice,
  });

  await logActivity({
    userId: context.actorId,
    action: 'EDIT_PRICE',
    entityType: 'PartPrice',
    entityId: `${modelId}:${partId}:${quality}`,
    previousValue: existing
      ? { buyPrice: existing.buyPrice, sellPrice: existing.sellPrice }
      : undefined,
    newValue: { buyPrice, sellPrice: newSellPrice, needsReview, source: 'AUTO_ON_PURCHASE' },
    ip: context.ip,
    device: context.device,
  });

  return { newSellPrice, needsReview };
}

// ----- نمایش و مدیریت قیمت‌ها — docs/15-pricing-integration.md -----

import {
  listPricesByModel,
  listNeedsReview,
  setPartPriceManual,
  listPriceHistory,
} from '../repositories/part-price.repository';
import type {
  ModelPriceRow,
  ReviewItem,
  PriceHistoryItem,
  QualityPrice,
} from '../types/price.types';
import type { SetPriceInput } from '../validators/set-price.schema';

/** قیمت‌های یک مدل — includeBuy فقط برای دارندگان EDIT_PRICE true می‌شود */
export async function getModelPricesService(
  modelId: string,
  includeBuy: boolean,
): Promise<ModelPriceRow[]> {
  const prices = await listPricesByModel(modelId);
  const rows = new Map<string, ModelPriceRow>();

  for (const price of prices) {
    // صفحه عمومی/پذیرش: فقط ردیف‌های دارای قیمت فروش
    if (!includeBuy && price.sellPrice === null) continue;

    const row = rows.get(price.partId) ?? {
      partId: price.partId,
      partName: price.part.name,
      prices: {},
    };

    const qualityPrice: QualityPrice = {
      sellPrice: price.sellPrice,
      notes: price.notes,
      ...(includeBuy && { buyPrice: price.buyPrice, needsReview: price.needsReview }),
    };

    row.prices[price.quality] = qualityPrice;
    rows.set(price.partId, row);
  }

  return [...rows.values()];
}

export async function listNeedsReviewService(): Promise<ReviewItem[]> {
  const items = await listNeedsReview();

  return items.map((item) => ({
    modelId: item.modelId,
    modelName: item.model.name,
    brandName: item.model.brand.name,
    partId: item.partId,
    partName: item.part.name,
    quality: item.quality,
    buyPrice: item.buyPrice,
    sellPrice: item.sellPrice,
  }));
}

/** ثبت/ویرایش دستی قیمت توسط ادمین */
export async function setPriceService(input: SetPriceInput, context: ActorContext) {
  const existing = await findPartPrice(input.modelId, input.partId, input.quality);

  const updated = await setPartPriceManual(input);

  // Price History Rules — فقط مقادیر تغییرکرده ثبت می‌شوند
  if (input.buyPrice !== undefined && input.buyPrice !== null && input.buyPrice !== existing?.buyPrice) {
    await createPriceHistory({
      partId: input.partId,
      modelId: input.modelId,
      quality: input.quality,
      purchaseId: null,
      type: 'BUY',
      price: input.buyPrice,
    });
  }

  if (input.sellPrice !== undefined && input.sellPrice !== null && input.sellPrice !== existing?.sellPrice) {
    await createPriceHistory({
      partId: input.partId,
      modelId: input.modelId,
      quality: input.quality,
      purchaseId: null,
      type: 'SELL',
      price: input.sellPrice,
    });
  }

  await logActivity({
    userId: context.actorId,
    action: 'EDIT_PRICE',
    entityType: 'PartPrice',
    entityId: `${input.modelId}:${input.partId}:${input.quality}`,
    previousValue: existing
      ? { buyPrice: existing.buyPrice, sellPrice: existing.sellPrice }
      : undefined,
    newValue: { buyPrice: updated.buyPrice, sellPrice: updated.sellPrice, source: 'MANUAL' },
    ip: context.ip,
    device: context.device,
  });

  return updated;
}

export async function getPriceHistoryService(
  modelId: string,
  partId: string,
): Promise<PriceHistoryItem[]> {
  const history = await listPriceHistory(modelId, partId);

  return history.map((entry) => ({
    id: entry.id,
    type: entry.type,
    quality: entry.quality,
    price: entry.price,
    recordedAt: entry.recordedAt,
  }));
}
