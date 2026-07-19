'use client';

import { useQuery } from '@tanstack/react-query';
import type { PartQuality } from '@prisma/client';
import { apiFetch } from '@/shared/lib/api-client';

export type PriceCheckResult = {
  isBelowLastBuy: boolean;
  lastBuyPrice: number | null;
  hasBuyPrice: boolean;
};

/** بررسی اینکه قیمت اعلامی از آخرین قیمت خرید کمتر است یا نه */
export function usePriceCheck(params: {
  modelId: string | null;
  partId: string;
  quality: PartQuality;
  price: string;
}) {
  const numericPrice = Number(params.price) || 0;
  const enabled = Boolean(params.modelId && params.partId && numericPrice > 0);

  return useQuery({
    queryKey: ['price-check', params],
    enabled,
    queryFn: () =>
      apiFetch<PriceCheckResult>(
        `/api/v1/part-prices/check?modelId=${params.modelId}&partId=${params.partId}&quality=${params.quality}&price=${numericPrice}`,
      ),
  });
}
