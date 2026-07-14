'use client';

import { useState } from 'react';
import { Loader2, TriangleAlert } from 'lucide-react';
import type { PartQuality } from '@prisma/client';
import { Button } from '@/shared/components/ui/button';
import { Dialog } from '@/shared/components/ui/dialog';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { useToast } from '@/shared/components/providers/toast-provider';
import { ModelCascadePicker } from './model-cascade-picker';
import { PriceTable } from './price-table';
import { useModelPrices, useNeedsReview, useSetPrice, usePriceHistory } from '../hooks/use-prices';
import type { ModelPriceRow } from '../types/price.types';
import { QUALITY_LABELS } from '@/features/part-requests/constants/state-machine.constants';

type EditTarget = { row: ModelPriceRow; quality: PartQuality };

type AdminPricesViewProps = { canEdit: boolean };

export function AdminPricesView({ canEdit }: AdminPricesViewProps) {
  const { toast } = useToast();
  const [modelId, setModelId] = useState('');
  const [editTarget, setEditTarget] = useState<EditTarget | null>(null);
  const [historyTarget, setHistoryTarget] = useState<ModelPriceRow | null>(null);
  const [buyPrice, setBuyPrice] = useState('');
  const [sellPrice, setSellPrice] = useState('');
  const [notes, setNotes] = useState('');

  const prices = useModelPrices(modelId, false);
  const review = useNeedsReview(canEdit);
  const setPrice = useSetPrice();
  const history = usePriceHistory(
    historyTarget ? modelId : null,
    historyTarget?.partId ?? null,
  );

  const openEdit = (row: ModelPriceRow, quality: PartQuality) => {
    if (!canEdit) return;
    const current = row.prices[quality];
    setBuyPrice(current?.buyPrice != null ? String(current.buyPrice) : '');
    setSellPrice(current?.sellPrice != null ? String(current.sellPrice) : '');
    setNotes(current?.notes ?? '');
    setEditTarget({ row, quality });
  };

  const handleSave = () => {
    if (!editTarget) return;
    setPrice.mutate(
      {
        modelId,
        partId: editTarget.row.partId,
        quality: editTarget.quality,
        ...(buyPrice.trim() && { buyPrice: buyPrice.trim() }),
        ...(sellPrice.trim() && { sellPrice: sellPrice.trim() }),
        notes: notes.trim() || null,
      },
      {
        onSuccess: () => { toast('قیمت ذخیره شد'); setEditTarget(null); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-extrabold">قیمت قطعات</h1>

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

      <ModelCascadePicker onModelChange={setModelId} />

      {modelId ? (
        <PriceTable
          rows={prices.data}
          isLoading={prices.isLoading}
          showBuy={canEdit}
          onEdit={canEdit ? openEdit : undefined}
          onHistory={setHistoryTarget}
        />
      ) : (
        <p className="rounded-lg border border-border bg-card py-10 text-center text-sm font-semibold text-muted-foreground">
          برای مشاهده و مدیریت قیمت‌ها، مدل را انتخاب کنید
        </p>
      )}

      <Dialog
        open={editTarget !== null}
        onClose={() => setEditTarget(null)}
        title={
          editTarget
            ? `${editTarget.row.partName} — ${QUALITY_LABELS[editTarget.quality]}`
            : ''
        }
      >
        <div className="flex flex-col gap-3.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editBuy">قیمت خرید (تومان)</Label>
            <Input
              id="editBuy"
              inputMode="numeric"
              value={buyPrice}
              onChange={(event) => setBuyPrice(event.target.value)}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editSell">قیمت فروش (تومان)</Label>
            <Input
              id="editSell"
              inputMode="numeric"
              value={sellPrice}
              onChange={(event) => setSellPrice(event.target.value)}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editNotes">یادداشت (اختیاری)</Label>
            <Textarea id="editNotes" rows={2} value={notes} onChange={(event) => setNotes(event.target.value)} />
          </div>
          <Button onClick={handleSave} disabled={setPrice.isPending}>
            {setPrice.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
            ذخیره قیمت
          </Button>
        </div>
      </Dialog>

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
