'use client';

import { useEffect, useMemo, useState } from 'react';
import { Loader2 } from 'lucide-react';
import type { PartQuality } from '@prisma/client';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Select } from '@/shared/components/ui/select';
import { Textarea } from '@/shared/components/ui/textarea';
import { Switch } from '@/shared/components/ui/switch';
import { PromptDialog } from '@/shared/components/ui/prompt-dialog';
import { useToast } from '@/shared/components/providers/toast-provider';
import { cn } from '@/shared/lib/cn';
import { useCreatePartRequest } from '../hooks/use-part-request-mutations';
import { usePartOptions } from '../hooks/use-part-requests';
import { useTaxonomy, useCreateModel } from '../hooks/use-taxonomy';
import { useQuickCreate } from '../hooks/use-quick-create';
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
  const [modelName, setModelName] = useState('');
  const [partId, setPartId] = useState('');
  const [quality, setQuality] = useState<PartQuality>('ORIGINAL');
  const [quantity, setQuantity] = useState('1');
  const [announcedPrice, setAnnouncedPrice] = useState('');
  const [isTest, setIsTest] = useState(false);
  const [description, setDescription] = useState('');

  const [isBrandPromptOpen, setIsBrandPromptOpen] = useState(false);
  const [isCreatingBrand, setIsCreatingBrand] = useState(false);
  const [isPartPromptOpen, setIsPartPromptOpen] = useState(false);
  const [isCreatingPart, setIsCreatingPart] = useState(false);

  useEffect(() => {
    if (!open) return;
    setReceptionNumber('');
    setDeviceTypeId('');
    setBrandId('');
    setModelName('');
    setPartId('');
    setQuality('ORIGINAL');
    setQuantity('1');
    setAnnouncedPrice('');
    setIsTest(false);
    setDescription('');
  }, [open]);

  // مدل‌های فیلترشده بر اساس نوع دستگاه و برند انتخابی
  const filteredModels = useMemo(() => {
    if (!taxonomy.data || !brandId) return [];
    return taxonomy.data.models.filter(
      (model) =>
        model.brandId === brandId &&
        (!deviceTypeId || model.deviceTypeId === deviceTypeId || model.deviceTypeId === null),
    );
  }, [taxonomy.data, brandId, deviceTypeId]);

  const matchedModel = filteredModels.find(
    (model) => model.name.trim() === modelName.trim(),
  );
  const isNewModel = Boolean(modelName.trim() && brandId && !matchedModel);

  const handleSubmit = async () => {
    if (!deviceTypeId || !brandId || !modelName.trim()) {
      toast('نوع دستگاه، برند و مدل را مشخص کنید', 'error');
      return;
    }
    if (!partId) {
      toast('قطعه را انتخاب کنید', 'error');
      return;
    }

    try {
      // مدل موجود نبود → ثبت مدل جدید در لحظه (docs/15-pricing-integration.md)
      let modelId = matchedModel?.id;
      if (!modelId) {
        const created = await createModel.mutateAsync({
          name: modelName.trim(),
          deviceTypeId,
          brandId,
        });
        modelId = created.id;
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
    } catch (error) {
      toast(error instanceof Error ? error.message : 'خطا در ثبت مدل', 'error');
    }
  };

  const isPending = createRequest.isPending || createModel.isPending;

  return (
    <Dialog open={open} onClose={onClose} title="درخواست قطعه جدید">
      <div className="flex flex-col gap-3.5">
        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="receptionNumber">شماره پذیرش</Label>
            <Input
              id="receptionNumber"
              inputMode="numeric"
              placeholder="مثلاً: 1042"
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
            <Select
              id="deviceType"
              value={deviceTypeId}
              onChange={(event) => { setDeviceTypeId(event.target.value); setModelName(''); }}
            >
              <option value="">انتخاب کنید…</option>
              {taxonomy.data?.deviceTypes.map((type) => (
                <option key={type.id} value={type.id}>{type.name}</option>
              ))}
            </Select>
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="brand">برند</Label>
            <div className="flex gap-1.5">
              <Select
                id="brand"
                value={brandId}
                onChange={(event) => { setBrandId(event.target.value); setModelName(''); }}
              >
                <option value="">انتخاب کنید…</option>
                {taxonomy.data?.brands.map((brand) => (
                  <option key={brand.id} value={brand.id}>{brand.name}</option>
                ))}
              </Select>
              <button
                type="button"
                title="افزودن برند جدید"
                onClick={() => setIsBrandPromptOpen(true)}
                className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md border border-border bg-card text-lg font-bold text-primary"
              >
                +
              </button>
            </div>
          </div>
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="model">مدل</Label>
          <Input
            id="model"
            list="model-options"
            placeholder="جستجو یا ورود مدل جدید…"
            value={modelName}
            disabled={!brandId}
            onChange={(event) => setModelName(event.target.value)}
          />
          <datalist id="model-options">
            {filteredModels.map((model) => <option key={model.id} value={model.name} />)}
          </datalist>
          {isNewModel && (
            <p className="text-[11px] font-semibold text-accent-foreground">
              مدل «{modelName.trim()}» جدید است و هنگام ثبت به دسته‌بندی اضافه می‌شود.
            </p>
          )}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="partId">قطعه</Label>
          <div className="flex gap-1.5">
            <Select
              id="partId"
              value={partId}
              onChange={(event) => setPartId(event.target.value)}
            >
              <option value="">انتخاب کنید…</option>
              {partOptions.data?.map((part) => (
                <option key={part.id} value={part.id}>{part.name}</option>
              ))}
            </Select>
            <button
              type="button"
              title="افزودن قطعه جدید"
              onClick={() => setIsPartPromptOpen(true)}
              className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md border border-border bg-card text-lg font-bold text-primary"
            >
              +
            </button>
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

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="announcedPrice">قیمت اعلامی به مشتری (تومان — اختیاری)</Label>
          <Input
            id="announcedPrice"
            inputMode="numeric"
            placeholder="مثلاً: 2500000"
            value={announcedPrice}
            onChange={(event) => setAnnouncedPrice(event.target.value)}
          />
          <p className="text-[11px] text-muted-foreground">
            در صورت وارد کردن قیمت، درخواست مستقیم به «در انتظار تایید مشتری» می‌رود.
          </p>
        </div>

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

        <PromptDialog
          open={isBrandPromptOpen}
          title="افزودن برند جدید"
          label="نام برند"
          placeholder="مثلاً: Nokia"
          isPending={isCreatingBrand}
          onClose={() => setIsBrandPromptOpen(false)}
          onSubmit={async (name) => {
            setIsCreatingBrand(true);
            try {
              const created = await quickCreate.createBrand(name);
              setBrandId(created.id);
              setModelName('');
              toast('برند افزوده شد');
              setIsBrandPromptOpen(false);
            } catch (error) {
              toast(error instanceof Error ? error.message : 'خطا', 'error');
            } finally {
              setIsCreatingBrand(false);
            }
          }}
        />

        <PromptDialog
          open={isPartPromptOpen}
          title="افزودن قطعه جدید"
          label="نام قطعه"
          placeholder="مثلاً: تاچ"
          isPending={isCreatingPart}
          onClose={() => setIsPartPromptOpen(false)}
          onSubmit={async (name) => {
            setIsCreatingPart(true);
            try {
              const created = await quickCreate.createPart(name);
              setPartId(created.id);
              toast('قطعه افزوده شد');
              setIsPartPromptOpen(false);
            } catch (error) {
              toast(error instanceof Error ? error.message : 'خطا', 'error');
            } finally {
              setIsCreatingPart(false);
            }
          }}
        />

        <Button onClick={handleSubmit} disabled={isPending}>
          {isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ثبت درخواست
        </Button>
      </div>
    </Dialog>
  );
}
