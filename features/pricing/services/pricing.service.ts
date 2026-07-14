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
