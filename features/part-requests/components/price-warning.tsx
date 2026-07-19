'use client';

import { TriangleAlert } from 'lucide-react';
import type { PriceCheckResult } from '../hooks/use-price-check';

export function PriceWarning({ check }: { check: PriceCheckResult | undefined }) {
  if (!check?.isBelowLastBuy) return null;

  return (
    <div className="flex items-start gap-2 rounded-md border border-[#f0d878] bg-[#fef9e7] px-3.5 py-3 text-[12.5px] font-semibold leading-6 text-[#92730c] dark:border-[#4d4014] dark:bg-[#332b0f] dark:text-[#fbbf24]">
      <TriangleAlert className="mt-0.5 h-4 w-4 shrink-0" />
      <span>
        قیمت اعلامی از آخرین قیمت خرید این قطعه کمتر است
        {check.lastBuyPrice !== null &&
          ` (آخرین خرید: ${check.lastBuyPrice.toLocaleString('fa-IR')} تومان)`}
        . ثبت امکان‌پذیر است اما بازبینی توصیه می‌شود.
      </span>
    </div>
  );
}
