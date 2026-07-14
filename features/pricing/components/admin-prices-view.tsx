'use client';

import { useState } from 'react';
import { Plus, TriangleAlert } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Dialog } from '@/shared/components/ui/dialog';
import { PriceListView } from './price-list-view';
import { PriceEditDialog } from './price-edit-dialog';
import { useNeedsReview, usePriceHistory } from '../hooks/use-prices';
import type { PriceListRow } from '../types/price.types';
import { QUALITY_LABELS } from '@/features/part-requests/constants/state-machine.constants';

type AdminPricesViewProps = { canEdit: boolean };

export function AdminPricesView({ canEdit }: AdminPricesViewProps) {
  const [editTarget, setEditTarget] = useState<PriceListRow | null>(null);
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [historyTarget, setHistoryTarget] = useState<PriceListRow | null>(null);

  const review = useNeedsReview(canEdit);
  const history = usePriceHistory(historyTarget?.modelId ?? null, historyTarget?.partId ?? null);

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-extrabold">قیمت قطعات</h1>
        {canEdit && (
          <Button className="h-10 w-auto px-4 text-[13px]" onClick={() => setIsAddOpen(true)}>
            <Plus className="h-4 w-4" />
            افزودن قیمت
          </Button>
        )}
      </div>

      {canEdit && review.data && review.data.length > 0 && (
        <div className="rounded-lg border border-[#f0d878] bg-[#fef9e7] p-3.5 dark:border-[#4d4014] dark:bg-[#332b0f]">
          <div className="flex items-center gap-2 text-[13px] font-extrabold text-[#92730c] dark:text-[#fbbf24]">
            <TriangleAlert className="h-4 w-4" />
            {review.data.length} قیمت نیاز به بازبینی دارد (فروش خودکار +۳۰٪)
          </div>
          <div className="mt-2 space-y-1">
            {review.data.slice(0, 5).map((item) => (
              <div
                key={`${item.modelId}-${item.partId}-${item.quality}`}
                className="text-[12px] font-semibold text-[#92730c] dark:text-[#fbbf24]"
              >
                {item.brandName} {item.modelName} — {item.partName} ({QUALITY_LABELS[item.quality]})
                — فروش: {item.sellPrice?.toLocaleString('fa-IR') ?? '—'}
              </div>
            ))}
            {review.data.length > 5 && (
              <div className="text-[11px] text-[#92730c] dark:text-[#fbbf24]">
                و {review.data.length - 5} مورد دیگر…
              </div>
            )}
          </div>
        </div>
      )}

      <PriceListView
        isPublic={false}
        showBuy={canEdit}
        onEdit={canEdit ? setEditTarget : undefined}
        onHistory={setHistoryTarget}
      />

      <PriceEditDialog
        open={editTarget !== null || isAddOpen}
        row={editTarget}
        onClose={() => { setEditTarget(null); setIsAddOpen(false); }}
      />

      <Dialog
        open={historyTarget !== null}
        onClose={() => setHistoryTarget(null)}
        title={`تاریخچه قیمت — ${historyTarget?.partName ?? ''}`}
      >
        <div className="max-h-80 space-y-1.5 overflow-y-auto">
          {history.data?.length === 0 && (
            <p className="py-6 text-center text-sm text-muted-foreground">تاریخچه‌ای ثبت نشده</p>
          )}
          {history.data?.map((entry) => (
            <div
              key={entry.id}
              className="flex items-center justify-between rounded-md border border-border bg-background px-3 py-2 text-[12.5px]"
            >
              <span className="font-bold">
                {entry.type === 'BUY' ? 'خرید' : 'فروش'}
                {entry.quality && ` — ${QUALITY_LABELS[entry.quality]}`}
              </span>
              <span className="font-extrabold">{entry.price.toLocaleString('fa-IR')}</span>
              <span className="text-muted-foreground">
                {new Date(entry.recordedAt).toLocaleDateString('fa-IR')}
              </span>
            </div>
          ))}
        </div>
      </Dialog>
    </div>
  );
}
