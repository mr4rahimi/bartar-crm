'use client';

import { useEffect, useMemo, useState } from 'react';
import { Loader2 } from 'lucide-react';
import type { PartQuality } from '@prisma/client';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { Switch } from '@/shared/components/ui/switch';
import { PriceInput } from '@/shared/components/ui/price-input';
import { SearchableSelect } from '@/shared/components/ui/searchable-select';
import { useToast } from '@/shared/components/providers/toast-provider';
import { cn } from '@/shared/lib/cn';
import { useUpdatePartRequest } from '../hooks/use-part-request-mutations';
import { usePartOptions } from '../hooks/use-part-requests';
import { useTaxonomy } from '../hooks/use-taxonomy';
import { QUALITY_LABELS } from '../constants/state-machine.constants';
import type { PartRequestDetailDto } from '../types/part-request.types';

const QUALITIES: PartQuality[] = ['ORIGINAL', 'HIGH_COPY', 'COPY'];

type EditDialogProps = {
  open: boolean;
  request: PartRequestDetailDto;
  onClose: () => void;
};

export function PartRequestEditDialog({ open, request, onClose }: EditDialogProps) {
  const { toast } = useToast();
  const updateRequest = useUpdatePartRequest();
  const partOptions = usePartOptions();
  const taxonomy = useTaxonomy();

  const [receptionNumber, setReceptionNumber] = useState('');
  const [partId, setPartId] = useState('');
  const [brandId, setBrandId] = useState('');
  const [modelId, setModelId] = useState('');
  const [quality, setQuality] = useState<PartQuality>('ORIGINAL');
  const [quantity, setQuantity] = useState('1');
  const [announcedPrice, setAnnouncedPrice] = useState('');
  const [depositAmount, setDepositAmount] = useState('');
  const [isTest, setIsTest] = useState(false);
  const [description, setDescription] = useState('');

  useEffect(() => {
    if (!open) return;
    setReceptionNumber(request.receptionNumber);
    setPartId(request.partId);
    setModelId(request.modelId ?? '');
    setQuality(request.quality);
    setQuantity(String(request.quantity));
    setAnnouncedPrice(request.announcedPrice != null ? String(request.announcedPrice) : '');
    setDepositAmount(request.depositAmount ? String(request.depositAmount) : '');
    setIsTest(request.isTest);
    setDescription(request.description ?? '');

    const currentModel = taxonomy.data?.models.find((model) => model.id === request.modelId);
    setBrandId(currentModel?.brandId ?? '');
  }, [open, request, taxonomy.data]);

  const filteredModels = useMemo(() => {
    if (!taxonomy.data || !brandId) return [];
    return taxonomy.data.models
      .filter((model) => model.brandId === brandId)
      .map((model) => ({ id: model.id, name: model.name }));
  }, [taxonomy.data, brandId]);

  const handleSubmit = () => {
    updateRequest.mutate(
      {
        requestId: request.id,
        receptionNumber: receptionNumber.trim(),
        partId,
        modelId: modelId || null,
        quality,
        quantity,
        announcedPrice: announcedPrice.trim() || null,
        depositAmount: depositAmount.trim() || null,
        isTest,
        description: description.trim() || null,
      },
      {
        onSuccess: () => { toast('تغییرات ذخیره شد'); onClose(); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  return (
    <Dialog open={open} onClose={onClose} title="ویرایش درخواست">
      <div className="flex flex-col gap-3.5">
        <p className="rounded-md border border-border bg-background px-3.5 py-2.5 text-[11.5px] text-muted-foreground">
          ویرایش مدیریتی: تمام تغییرات در تاریخچه ثبت می‌شود.
        </p>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editReception">شماره پذیرش</Label>
            <Input
              id="editReception"
              inputMode="numeric"
              value={receptionNumber}
              onChange={(event) => setReceptionNumber(event.target.value)}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editQuantity">تعداد</Label>
            <Input
              id="editQuantity"
              inputMode="numeric"
              value={quantity}
              onChange={(event) => setQuantity(event.target.value)}
            />
          </div>
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="editPart">قطعه</Label>
          <SearchableSelect
            id="editPart"
            items={partOptions.data ?? []}
            value={partId}
            onChange={setPartId}
          />
        </div>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editBrand">برند</Label>
            <SearchableSelect
              id="editBrand"
              items={taxonomy.data?.brands ?? []}
              value={brandId}
              onChange={(id) => { setBrandId(id); setModelId(''); }}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editModel">مدل</Label>
            <SearchableSelect
              id="editModel"
              items={filteredModels}
              value={modelId}
              onChange={setModelId}
              disabled={!brandId}
              emptyText="مدلی برای این برند نیست"
            />
          </div>
        </div>

        <div className="flex flex-col gap-1.5">
          <Label>کیفیت</Label>
          <div className="flex gap-2">
            {QUALITIES.map((value) => (
              <button
                key={value}
                type="button"
                onClick={() => setQuality(value)}
                className={cn(
                  'flex-1 rounded-md border px-3 py-2.5 text-[13px] font-bold',
                  quality === value
                    ? 'border-primary bg-accent text-accent-foreground'
                    : 'border-border bg-card text-muted-foreground',
                )}
              >
                {QUALITY_LABELS[value]}
              </button>
            ))}
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editAnnounced">قیمت اعلامی</Label>
            <PriceInput id="editAnnounced" value={announcedPrice} onChange={setAnnouncedPrice} />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editDeposit">بیعانه</Label>
            <PriceInput id="editDeposit" value={depositAmount} onChange={setDepositAmount} />
          </div>
        </div>

        <div className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-3">
          <Label htmlFor="editIsTest">درخواست تستی</Label>
          <Switch id="editIsTest" checked={isTest} onCheckedChange={setIsTest} />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="editDescription">توضیح</Label>
          <Textarea
            id="editDescription"
            rows={2}
            value={description}
            onChange={(event) => setDescription(event.target.value)}
          />
        </div>

        <Button onClick={handleSubmit} disabled={updateRequest.isPending}>
          {updateRequest.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ذخیره تغییرات
        </Button>
      </div>
    </Dialog>
  );
}
