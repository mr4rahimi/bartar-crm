import type { PartQuality } from '@prisma/client';

export type QualityPrice = {
  sellPrice: number | null;
  buyPrice?: number | null; // فقط برای EDIT_PRICE
  needsReview?: boolean;
  notes: string | null;
};

export type ModelPriceRow = {
  partId: string;
  partName: string;
  prices: Partial<Record<PartQuality, QualityPrice>>;
};

export type ReviewItem = {
  modelId: string;
  modelName: string;
  brandName: string;
  partId: string;
  partName: string;
  quality: PartQuality;
  buyPrice: number | null;
  sellPrice: number | null;
};

export type PriceHistoryItem = {
  id: string;
  type: 'BUY' | 'SELL';
  quality: PartQuality | null;
  price: number;
  recordedAt: Date;
};

export type PriceListRow = {
  modelId: string;
  partId: string;
  deviceTypeName: string | null;
  brandName: string;
  modelName: string;
  partName: string;
  updatedAt: Date;
  prices: Partial<Record<PartQuality, QualityPrice>>;
};
