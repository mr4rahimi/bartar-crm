'use client';

import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';
import type { PartQuality } from '@prisma/client';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { PriceInput } from '@/shared/components/ui/price-input';
import { Label } from '@/shared/components/ui/label';
import { Select } from '@/shared/components/ui/select';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useTaxonomy } from '@/features/part-requests/hooks/use-taxonomy';
import { ModelCascadePicker } from './model-cascade-picker';
import { useSetPrice } from '../hooks/use-prices';
import type { PriceListRow } from '../types/price.types';

const QUALITIES: { quality: PartQuality; label: string }[] = [
  { quality: 'COPY', label: 'کپی' },
  { quality: 'HIGH_COPY', label: 'های‌کپی' },
  { quality: 'ORIGINAL', label: 'اورجینال' },
];

type PriceEditDialogProps = {
  open: boolean;
  row: PriceListRow | null; // null = افزودن قیمت جدید
  onClose: () => void;
};

type PriceFields = Record<PartQuality, { buy: string; sell: string }>;

const emptyFields = (): PriceFields => ({
  COPY: { buy: '', sell: '' },
  HIGH_COPY: { buy: '', sell: '' },
  ORIGINAL: { buy: '', sell: '' },
});

export function PriceEditDialog({ open, row, onClose }: PriceEditDialogProps) {
  const isEdit = row !== null;
  const { toast } = useToast();
  const taxonomy = useTaxonomy();
  const setPrice = useSetPrice();

  const [modelId, setModelId] = useState('');
  const [partId, setPartId] = useState('');
  const [fields, setFields] = useState<PriceFields>(emptyFields());
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (!open) return;
    setModelId(row?.modelId ?? '');
    setPartId(row?.partId ?? '');
    const next = emptyFields();
    if (row) {
      for (const { quality } of QUALITIES) {
        const price = row.prices[quality];
        next[quality] = {
          buy: price?.buyPrice != null ? String(price.buyPrice) : '',
          sell: price?.sellPrice != null ? String(price.sellPrice) : '',
        };
      }
    }
    setFields(next);
  }, [open, row]);

  const setField = (quality: PartQuality, kind: 'buy' | 'sell', value: string) => {
    setFields((current) => ({
      ...current,
      [quality]: { ...current[quality], [kind]: value },
    }));
  };

  const handleSave = async () => {
    if (!modelId || !partId) {
      toast('مدل و قطعه را انتخاب کنید', 'error');
      return;
    }

    const updates = QUALITIES.filter(
      ({ quality }) => fields[quality].buy.trim() || fields[quality].sell.trim(),
    );
    if (updates.length === 0) {
      toast('حداقل یک قیمت وارد کنید', 'error');
      return;
    }

    setIsSaving(true);
    try {
      for (const { quality } of updates) {
        await setPrice.mutateAsync({
          modelId,
          partId,
          quality,
          ...(fields[quality].buy.trim() && { buyPrice: fields[quality].buy.trim() }),
          ...(fields[quality].sell.trim() && { sellPrice: fields[quality].sell.trim() }),
        });
      }
      toast('قیمت‌ها ذخیره شدند');
      onClose();
    } catch (error) {
      toast(error instanceof Error ? error.message : 'خطا در ذخیره', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <Dialog
      open={open}
      onClose={onClose}
      title={isEdit ? `ویرایش قیمت — ${row.brandName} ${row.modelName} / ${row.partName}` : 'افزودن قیمت'}
    >
      <div className="flex flex-col gap-3.5">
        {!isEdit && (
          <>
            <ModelCascadePicker onModelChange={setModelId} />
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="pricePart">قطعه</Label>
              <Select id="pricePart" value={partId} onChange={(event) => setPartId(event.target.value)}>
                <option value="">انتخاب کنید…</option>
                {taxonomy.data?.parts.map((part) => (
                  <option key={part.id} value={part.id}>{part.name}</option>
                ))}
              </Select>
            </div>
          </>
        )}

        <div className="space-y-2.5">
          {QUALITIES.map(({ quality, label }) => (
            <div key={quality} className="rounded-md border border-border bg-background p-3">
              <div className="mb-2 text-[12.5px] font-extrabold">{label}</div>
              <div className="grid grid-cols-2 gap-2">
                <div className="flex flex-col gap-1">
                  <Label className="text-[11px]">قیمت فروش</Label>
                  <PriceInput
                    value={fields[quality].sell}
                    onChange={(raw) => setField(quality, 'sell', raw)}
                  />
                </div>
                <div className="flex flex-col gap-1">
                  <Label className="text-[11px]">قیمت خرید</Label>
                  <PriceInput
                    value={fields[quality].buy}
                    onChange={(raw) => setField(quality, 'buy', raw)}
                  />
                </div>
              </div>
            </div>
          ))}
        </div>

        <Button onClick={handleSave} disabled={isSaving}>
          {isSaving && <Loader2 className="h-4 w-4 animate-spin" />}
          ذخیره قیمت‌ها
        </Button>
      </div>
    </Dialog>
  );
}
