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
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { cn } from '@/shared/lib/cn';
import { useCreatePartRequest } from '../hooks/use-part-request-mutations';
import { usePartOptions } from '../hooks/use-part-requests';
import { useTaxonomy, useCreateModel } from '../hooks/use-taxonomy';
import { useQuickCreate } from '../hooks/use-quick-create';
import { usePriceCheck } from '../hooks/use-price-check';
import { PriceWarning } from './price-warning';
import { QUALITY_LABELS } from '../constants/state-machine.constants';

type PartRequestFormDialogProps = { open: boolean; onClose: () => void };

const QUALITIES: PartQuality[] = ['ORIGINAL', 'HIGH_COPY', 'COPY'];

export function PartRequestFormDialog({ open, onClose }: PartRequestFormDialogProps) {
  const { toast } = useToast();
  const createRequest = useCreatePartRequest();
  const createModel = useCreateModel();
  const quickCreate = useQuickCreate();
  const partOptions = usePartOptions();
  const taxonomy = useTaxonomy();

  const [receptionNumber, setReceptionNumber] = useState('');
  const [deviceTypeId, setDeviceTypeId] = useState('');
  const [brandId, setBrandId] = useState('');
  const [modelId, setModelId] = useState('');
  const [partId, setPartId] = useState('');
  const [quality, setQuality] = useState<PartQuality>('ORIGINAL');
  const [quantity, setQuantity] = useState('1');
  const [announcedPrice, setAnnouncedPrice] = useState('');
  const [isTest, setIsTest] = useState(false);
  const [description, setDescription] = useState('');
  const [isCreatingPart, setIsCreatingPart] = useState(false);

  useEffect(() => {
    if (!open) return;
    setReceptionNumber('');
    setDeviceTypeId('');
    setBrandId('');
    setModelId('');
    setPartId('');
    setQuality('ORIGINAL');
    setQuantity('1');
    setAnnouncedPrice('');
    setIsTest(false);
    setDescription('');
  }, [open]);

  const filteredModels = useMemo(() => {
    if (!taxonomy.data || !brandId) return [];
    return taxonomy.data.models
      .filter(
        (model) =>
          model.brandId === brandId &&
          (!deviceTypeId || model.deviceTypeId === deviceTypeId || model.deviceTypeId === null),
      )
      .map((model) => ({ id: model.id, name: model.name }));
  }, [taxonomy.data, brandId, deviceTypeId]);

  const debouncedPrice = useDebouncedValue(announcedPrice, 500);
  const priceCheck = usePriceCheck({
    modelId: modelId || null,
    partId,
    quality,
    price: debouncedPrice,
  });

  const handleSubmit = () => {
    if (!deviceTypeId || !brandId || !modelId) {
      toast('نوع دستگاه، برند و مدل را مشخص کنید', 'error');
      return;
    }
    if (!partId) {
      toast('قطعه را انتخاب کنید', 'error');
      return;
    }
    if (!receptionNumber.trim()) {
      toast('شماره پذیرش را وارد کنید', 'error');
      return;
    }

    createRequest.mutate(
      {
        receptionNumber,
        partId,
        quality,
        quantity,
        modelId,
        announcedPrice: announcedPrice.trim() || undefined,
        isTest,
        description: description.trim() || undefined,
      },
      {
        onSuccess: () => { toast('درخواست قطعه ثبت شد'); onClose(); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  return (
    <Dialog open={open} onClose={onClose} title="درخواست قطعه جدید">
      <div className="flex flex-col gap-3.5">
        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="receptionNumber">شماره پذیرش</Label>
            <Input
              id="receptionNumber"
              inputMode="numeric"
              placeholder="مثلاً: 20001"
              value={receptionNumber}
              onChange={(event) => setReceptionNumber(event.target.value)}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="quantity">تعداد</Label>
            <Input
              id="quantity"
              inputMode="numeric"
              value={quantity}
              onChange={(event) => setQuantity(event.target.value)}
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="deviceType">نوع دستگاه</Label>
            <SearchableSelect
              id="deviceType"
              items={taxonomy.data?.deviceTypes ?? []}
              value={deviceTypeId}
              onChange={(id) => { setDeviceTypeId(id); setModelId(''); }}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="brand">برند</Label>
            <SearchableSelect
              id="brand"
              items={taxonomy.data?.brands ?? []}
              value={brandId}
              onChange={(id) => { setBrandId(id); setModelId(''); }}
              createLabel="ثبت برند"
              onCreate={async (term) => {
                try {
                  const created = await quickCreate.createBrand(term);
                  setBrandId(created.id);
                  setModelId('');
                  toast('برند افزوده شد');
                } catch (error) {
                  toast(error instanceof Error ? error.message : 'خطا', 'error');
                }
              }}
            />
          </div>
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="model">مدل</Label>
          <SearchableSelect
            id="model"
            items={filteredModels}
            value={modelId}
            onChange={setModelId}
            disabled={!brandId}
            placeholder={brandId ? 'جستجو یا ثبت مدل…' : 'ابتدا برند را انتخاب کنید'}
            emptyText="مدلی برای این برند ثبت نشده"
            isCreating={createModel.isPending}
            createLabel="ثبت مدل"
            onCreate={async (term) => {
              if (!deviceTypeId) {
                toast('ابتدا نوع دستگاه را انتخاب کنید', 'error');
                return;
              }
              try {
                const created = await createModel.mutateAsync({
                  name: term,
                  deviceTypeId,
                  brandId,
                });
                setModelId(created.id);
                toast('مدل افزوده شد');
              } catch (error) {
                toast(error instanceof Error ? error.message : 'خطا', 'error');
              }
            }}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="partId">قطعه</Label>
          <SearchableSelect
            id="partId"
            items={partOptions.data ?? []}
            value={partId}
            onChange={setPartId}
            createLabel="ثبت قطعه"
            isCreating={isCreatingPart}
            onCreate={async (term) => {
              setIsCreatingPart(true);
              try {
                const created = await quickCreate.createPart(term);
                setPartId(created.id);
                toast('قطعه افزوده شد');
              } catch (error) {
                toast(error instanceof Error ? error.message : 'خطا', 'error');
              } finally {
                setIsCreatingPart(false);
              }
            }}
          />
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

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="announcedPrice">قیمت اعلامی به مشتری (تومان — اختیاری)</Label>
          <PriceInput
            id="announcedPrice"
            placeholder="مثلاً: ۲٬۵۰۰٬۰۰۰"
            value={announcedPrice}
            onChange={setAnnouncedPrice}
          />
          <p className="text-[11px] text-muted-foreground">
            در صورت وارد کردن قیمت، درخواست مستقیم به «در انتظار تایید مشتری» می‌رود.
          </p>
        </div>

        <PriceWarning check={priceCheck.data} />

        <div className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-3">
          <Label htmlFor="isTest">درخواست تستی</Label>
          <Switch id="isTest" checked={isTest} onCheckedChange={setIsTest} />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="prDescription">توضیح (اختیاری)</Label>
          <Textarea
            id="prDescription"
            rows={2}
            value={description}
            onChange={(event) => setDescription(event.target.value)}
          />
        </div>

        <Button onClick={handleSubmit} disabled={createRequest.isPending}>
          {createRequest.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ثبت درخواست
        </Button>
      </div>
    </Dialog>
  );
}
