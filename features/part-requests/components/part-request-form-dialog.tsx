'use client';

import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';
import type { PartQuality } from '@prisma/client';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { Switch } from '@/shared/components/ui/switch';
import { useToast } from '@/shared/components/providers/toast-provider';
import { cn } from '@/shared/lib/cn';
import { useCreatePartRequest } from '../hooks/use-part-request-mutations';
import { usePartOptions } from '../hooks/use-part-requests';
import { QUALITY_LABELS } from '../constants/state-machine.constants';

type PartRequestFormDialogProps = { open: boolean; onClose: () => void };

const QUALITIES: PartQuality[] = ['ORIGINAL', 'HIGH_COPY', 'COPY'];

export function PartRequestFormDialog({ open, onClose }: PartRequestFormDialogProps) {
  const { toast } = useToast();
  const createRequest = useCreatePartRequest();
  const partOptions = usePartOptions();

  const [receptionNumber, setReceptionNumber] = useState('');
  const [partName, setPartName] = useState('');
  const [quality, setQuality] = useState<PartQuality>('ORIGINAL');
  const [quantity, setQuantity] = useState('1');
  const [brand, setBrand] = useState('');
  const [model, setModel] = useState('');
  const [announcedPrice, setAnnouncedPrice] = useState('');
  const [isTest, setIsTest] = useState(false);
  const [description, setDescription] = useState('');

  useEffect(() => {
    if (!open) return;
    setReceptionNumber('');
    setPartName('');
    setQuality('ORIGINAL');
    setQuantity('1');
    setBrand('');
    setModel('');
    setAnnouncedPrice('');
    setIsTest(false);
    setDescription('');
  }, [open]);

  const handleSubmit = () => {
    createRequest.mutate(
      {
        receptionNumber,
        partName,
        quality,
        quantity,
        brand: brand.trim() || undefined,
        model: model.trim() || undefined,
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

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="partName">نام قطعه</Label>
          <Input
            id="partName"
            list="part-options"
            placeholder="مثلاً: LCD"
            value={partName}
            onChange={(event) => setPartName(event.target.value)}
          />
          <datalist id="part-options">
            {partOptions.data?.map((part) => <option key={part.id} value={part.name} />)}
          </datalist>
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
            <Label htmlFor="prBrand">برند (اختیاری)</Label>
            <Input id="prBrand" value={brand} onChange={(event) => setBrand(event.target.value)} />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="prModel">مدل (اختیاری)</Label>
            <Input id="prModel" value={model} onChange={(event) => setModel(event.target.value)} />
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

        <Button onClick={handleSubmit} disabled={createRequest.isPending}>
          {createRequest.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ثبت درخواست
        </Button>
      </div>
    </Dialog>
  );
}
