'use client';

import type { PartQuality } from '@prisma/client';
import { Tag, TriangleAlert } from 'lucide-react';
import { Skeleton } from '@/shared/components/ui/skeleton';
import type { ModelPriceRow } from '../types/price.types';
import { QUALITY_LABELS } from '@/features/part-requests/constants/state-machine.constants';

const QUALITIES: PartQuality[] = ['ORIGINAL', 'HIGH_COPY', 'COPY'];

function formatPrice(value: number | null | undefined) {
  return value === null || value === undefined ? '—' : value.toLocaleString('fa-IR');
}

type PriceTableProps = {
  rows: ModelPriceRow[] | undefined;
  isLoading: boolean;
  showBuy: boolean;
  onEdit?: (row: ModelPriceRow, quality: PartQuality) => void;
  onHistory?: (row: ModelPriceRow) => void;
};

export function PriceTable({ rows, isLoading, showBuy, onEdit, onHistory }: PriceTableProps) {
  if (isLoading) {
    return (
      <div className="space-y-2">
        {[1, 2, 3].map((key) => <Skeleton key={key} className="h-24 w-full" />)}
      </div>
    );
  }

  if (!rows || rows.length === 0) {
    return (
      <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12">
        <Tag className="h-8 w-8 text-muted-foreground" />
        <p className="text-sm font-semibold text-muted-foreground">قیمتی برای این مدل ثبت نشده</p>
      </div>
    );
  }

  return (
    <div className="space-y-2">
      {rows.map((row) => (
        <div key={row.partId} className="rounded-lg border border-border bg-card p-3.5">
          <div className="flex items-center justify-between">
            <div className="text-[13.5px] font-extrabold">{row.partName}</div>
            {onHistory && (
              <button
                type="button"
                onClick={() => onHistory(row)}
                className="text-[11.5px] font-bold text-primary hover:underline"
              >
                تاریخچه قیمت
              </button>
            )}
          </div>
          <div className="mt-2.5 grid grid-cols-3 gap-2">
            {QUALITIES.map((quality) => {
              const price = row.prices[quality];
              return (
                <button
                  key={quality}
                  type="button"
                  disabled={!onEdit}
                  onClick={() => onEdit?.(row, quality)}
                  className="rounded-md border border-border bg-background p-2.5 text-right disabled:cursor-default"
                >
                  <div className="flex items-center gap-1 text-[11px] font-bold text-muted-foreground">
                    {QUALITY_LABELS[quality]}
                    {price?.needsReview && (
                      <TriangleAlert className="h-3 w-3 text-[#c2410c] dark:text-[#fb923c]" />
                    )}
                  </div>
                  <div className="mt-1 text-[13px] font-extrabold">
                    {formatPrice(price?.sellPrice)}
                  </div>
                  {showBuy && (
                    <div className="mt-0.5 text-[10.5px] text-muted-foreground">
                      خرید: {formatPrice(price?.buyPrice)}
                    </div>
                  )}
                </button>
              );
            })}
          </div>
        </div>
      ))}
    </div>
  );
}
