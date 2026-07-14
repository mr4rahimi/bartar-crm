'use client';

import { useEffect, useState } from 'react';
import { Loader2, TriangleAlert } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Select } from '@/shared/components/ui/select';
import { Textarea } from '@/shared/components/ui/textarea';
import { useToast } from '@/shared/components/providers/toast-provider';
import { normalizeDigits } from '@/shared/lib/normalize';
import type { PartRequestDto } from '@/features/part-requests/types/part-request.types';
import { useVendors, useRegisterPurchase } from '../hooks/use-purchases';

type PurchaseFormDialogProps = {
  request: PartRequestDto | null;
  onClose: () => void;
};

const NEW_VENDOR = '__new__';

export function PurchaseFormDialog({ request, onClose }: PurchaseFormDialogProps) {
  const { toast } = useToast();
  const vendors = useVendors();
  const registerPurchase = useRegisterPurchase();

  const [vendorId, setVendorId] = useState('');
  const [vendorName, setVendorName] = useState('');
  const [vendorPhone, setVendorPhone] = useState('');
  const [price, setPrice] = useState('');
  const [description, setDescription] = useState('');

  useEffect(() => {
    if (!request) return;
    setVendorId('');
    setVendorName('');
    setVendorPhone('');
    setPrice('');
    setDescription('');
  }, [request]);

  if (!request) return null;

  const numericPrice = Number(normalizeDigits(price.trim())) || 0;
  // Price Difference Rule — هشدار بدون مسدودسازی (docs/03-business-rules.md)
  const showPriceWarning =
    request.announcedPrice !== null && numericPrice > request.announcedPrice;

  const handleSubmit = () => {
    if (!vendorId) {
      toast('فروشنده را انتخاب کنید', 'error');
      return;
    }

    registerPurchase.mutate(
      {
        partRequestId: request.id,
        vendorId: vendorId === NEW_VENDOR ? undefined : vendorId,
        newVendor:
          vendorId === NEW_VENDOR
            ? { name: vendorName, phone: vendorPhone.trim() || undefined }
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

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="vendor">فروشنده</Label>
          <Select id="vendor" value={vendorId} onChange={(event) => setVendorId(event.target.value)}>
            <option value="">انتخاب کنید…</option>
            {vendors.data?.map((vendor) => (
              <option key={vendor.id} value={vendor.id}>{vendor.name}</option>
            ))}
            <option value={NEW_VENDOR}>+ فروشنده جدید</option>
          </Select>
        </div>

        {vendorId === NEW_VENDOR && (
          <div className="space-y-2.5 rounded-md border border-border bg-background p-3">
            <Input
              placeholder="نام فروشنده"
              value={vendorName}
              onChange={(event) => setVendorName(event.target.value)}
            />
            <Input
              dir="ltr"
              className="text-right"
              placeholder="موبایل (اختیاری)"
              value={vendorPhone}
              onChange={(event) => setVendorPhone(event.target.value)}
            />
          </div>
        )}

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="purchasePrice">قیمت خرید (تومان)</Label>
          <Input
            id="purchasePrice"
            inputMode="numeric"
            placeholder="مثلاً: 1700000"
            value={price}
            onChange={(event) => setPrice(event.target.value)}
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
