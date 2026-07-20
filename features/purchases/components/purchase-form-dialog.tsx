'use client';

import { useEffect, useState } from 'react';
import { Loader2, TriangleAlert } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { PriceInput } from '@/shared/components/ui/price-input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { useToast } from '@/shared/components/providers/toast-provider';
import { normalizeDigits } from '@/shared/lib/normalize';
import type { PartRequestDto } from '@/features/part-requests/types/part-request.types';
import { useRegisterPurchase } from '../hooks/use-purchases';
import { VendorPicker, type VendorSelection } from './vendor-picker';

type PurchaseFormDialogProps = {
  request: PartRequestDto | null;
  onClose: () => void;
};

export function PurchaseFormDialog({ request, onClose }: PurchaseFormDialogProps) {
  const { toast } = useToast();
  const registerPurchase = useRegisterPurchase();

  const [vendor, setVendor] = useState<VendorSelection>(null);
  const [price, setPrice] = useState('');
  const [description, setDescription] = useState('');

  useEffect(() => {
    if (!request) return;
    setVendor(null);
    setPrice('');
    setDescription('');
  }, [request]);

  if (!request) return null;

  const numericPrice = Number(normalizeDigits(price.trim())) || 0;
  // Price Difference Rule — هشدار بدون مسدودسازی (docs/03-business-rules.md)
  const showPriceWarning =
    request.announcedPrice !== null && numericPrice > request.announcedPrice;

  const handleSubmit = () => {
    if (!vendor) {
      toast('فروشنده را انتخاب کنید یا بسازید', 'error');
      return;
    }
    if (vendor.kind === 'new') {
      if (vendor.name.trim().length < 2) {
        toast('نام فروشنده را وارد کنید', 'error');
        return;
      }
      if (!vendor.phone.trim() && !vendor.landline.trim()) {
        toast('شماره همراه یا تلفن ثابت فروشنده را وارد کنید', 'error');
        return;
      }
    }
    if (numericPrice <= 0) {
      toast('قیمت خرید را وارد کنید', 'error');
      return;
    }

    registerPurchase.mutate(
      {
        partRequestId: request.id,
        vendorId: vendor.kind === 'existing' ? vendor.id : undefined,
        newVendor:
          vendor.kind === 'new'
            ? {
                name: vendor.name.trim(),
                phone: vendor.phone.trim() || undefined,
                landline: vendor.landline.trim() || undefined,
              }
            : undefined,
        price,
        description: description.trim() || undefined,
      },
      {
        onSuccess: ({ pricing }) => {
          toast(
            pricing.newSellPrice !== null
              ? `خرید ثبت شد — قیمت فروش جدید: ${pricing.newSellPrice.toLocaleString('fa-IR')} تومان${pricing.needsReview ? ' (نیاز به بازبینی ادمین)' : ''}`
              : 'خرید ثبت شد',
          );
          onClose();
        },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  return (
    <Dialog open onClose={onClose} title={`ثبت خرید — ${request.partName}`}>
      <div className="flex flex-col gap-3.5">
        <div className="rounded-md border border-border bg-background px-3.5 py-2.5 text-[12.5px] text-muted-foreground">
          پذیرش #{request.receptionNumber} — {request.quantity} عدد
          {request.announcedPrice !== null &&
            ` — قیمت اعلامی: ${request.announcedPrice.toLocaleString('fa-IR')} تومان`}
        </div>

        <VendorPicker value={vendor} onChange={setVendor} />

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="purchasePrice">قیمت خرید (تومان)</Label>
          <PriceInput
            id="purchasePrice"
            placeholder="مثلاً: ۱٬۷۰۰٬۰۰۰"
            value={price}
            onChange={setPrice}
          />
        </div>

        {showPriceWarning && (
          <div className="flex items-start gap-2 rounded-md border border-[#f0d878] bg-[#fef9e7] px-3.5 py-3 text-[12.5px] font-semibold leading-6 text-[#92730c] dark:border-[#4d4014] dark:bg-[#332b0f] dark:text-[#fbbf24]">
            <TriangleAlert className="mt-0.5 h-4 w-4 shrink-0" />
            <span>
              قیمت خرید ({numericPrice.toLocaleString('fa-IR')}) از قیمت اعلامی به مشتری (
              {request.announcedPrice!.toLocaleString('fa-IR')}) بیشتر است. ثبت امکان‌پذیر است
              اما هماهنگی با پذیرش/مشتری توصیه می‌شود.
            </span>
          </div>
        )}

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="purchaseDescription">توضیح (اختیاری)</Label>
          <Textarea
            id="purchaseDescription"
            rows={2}
            value={description}
            onChange={(event) => setDescription(event.target.value)}
          />
        </div>

        <Button onClick={handleSubmit} disabled={registerPurchase.isPending}>
          {registerPurchase.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ثبت خرید
        </Button>
      </div>
    </Dialog>
  );
}
