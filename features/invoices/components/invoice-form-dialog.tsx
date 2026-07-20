'use client';

import { useEffect, useState } from 'react';
import { Loader2, Plus, Printer, Trash2 } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Switch } from '@/shared/components/ui/switch';
import { PriceInput } from '@/shared/components/ui/price-input';
import { useToast } from '@/shared/components/providers/toast-provider';
import { cn } from '@/shared/lib/cn';
import { normalizeDigits } from '@/shared/lib/normalize';
import { useInvoiceByTicket, useCreateInvoice, useUpdateInvoice } from '../hooks/use-invoices';

type ItemRow = { key: string; title: string; quantity: string; unitPrice: string };

type InvoiceFormDialogProps = {
  ticket: { id: string; ticketNumber: string; customerName: string; customerPhone: string } | null;
  onClose: () => void;
};

const emptyRow = (): ItemRow => ({
  key: Math.random().toString(36).slice(2),
  title: '',
  quantity: '1',
  unitPrice: '',
});

const toNumber = (value: string) => Number(normalizeDigits(value.trim())) || 0;

export function InvoiceFormDialog({ ticket, onClose }: InvoiceFormDialogProps) {
  const { toast } = useToast();
  const existing = useInvoiceByTicket(ticket?.id ?? null);
  const createInvoice = useCreateInvoice();
  const updateInvoice = useUpdateInvoice();

  const [rows, setRows] = useState<ItemRow[]>([emptyRow()]);
  const [discountType, setDiscountType] = useState<'NONE' | 'PERCENT' | 'AMOUNT'>('NONE');
  const [discountValue, setDiscountValue] = useState('');
  const [warrantyMonths, setWarrantyMonths] = useState('');
  const [hasBatteryNote, setHasBatteryNote] = useState(false);
  const [extraNotes, setExtraNotes] = useState<string[]>([]);

  useEffect(() => {
    if (!ticket) return;
    const invoice = existing.data;

    if (invoice) {
      setRows(
        invoice.items.map((item) => ({
          key: item.id,
          title: item.title,
          quantity: String(item.quantity),
          unitPrice: String(item.unitPrice),
        })),
      );
      setDiscountType(invoice.discountType ?? 'NONE');
      setDiscountValue(invoice.discountValue != null ? String(invoice.discountValue) : '');
      setWarrantyMonths(invoice.warrantyMonths != null ? String(invoice.warrantyMonths) : '');
      setHasBatteryNote(invoice.hasBatteryNote);
      setExtraNotes(invoice.extraNotes);
    } else {
      setRows([emptyRow()]);
      setDiscountType('NONE');
      setDiscountValue('');
      setWarrantyMonths('');
      setHasBatteryNote(false);
      setExtraNotes([]);
    }
  }, [ticket, existing.data]);

  if (!ticket) return null;

  const updateRow = (key: string, patch: Partial<ItemRow>) => {
    setRows((current) => current.map((row) => (row.key === key ? { ...row, ...patch } : row)));
  };

  const subtotal = rows.reduce(
    (sum, row) => sum + toNumber(row.quantity) * toNumber(row.unitPrice),
    0,
  );
  const discountRaw = toNumber(discountValue);
  const discountAmount =
    discountType === 'PERCENT'
      ? Math.floor((subtotal * Math.min(discountRaw, 100)) / 100)
      : discountType === 'AMOUNT'
        ? Math.min(discountRaw, subtotal)
        : 0;
  const total = subtotal - discountAmount;

  const isPending = createInvoice.isPending || updateInvoice.isPending;

  const buildPayload = () => ({
    items: rows
      .filter((row) => row.title.trim() && toNumber(row.unitPrice) > 0)
      .map((row) => ({
        title: row.title.trim(),
        quantity: row.quantity,
        unitPrice: row.unitPrice,
      })),
    discountType: discountType === 'NONE' ? null : discountType,
    discountValue: discountType === 'NONE' ? null : discountValue || null,
    warrantyMonths: warrantyMonths || null,
    hasBatteryNote,
    extraNotes: extraNotes.filter((note) => note.trim()),
  });

  const handleSubmit = (thenPrint: boolean) => {
    const payload = buildPayload();
    if (payload.items.length === 0) {
      toast('حداقل یک قلم با شرح و قیمت وارد کنید', 'error');
      return;
    }

    const onSuccess = (invoice: { id: string }) => {
      toast('فاکتور ذخیره شد');
      if (thenPrint) window.open(`/invoices/${invoice.id}/print`, '_blank');
      onClose();
    };
    const onError = (error: Error) => toast(error.message, 'error');

    if (existing.data) {
      updateInvoice.mutate({ invoiceId: existing.data.id, ...payload }, { onSuccess, onError });
    } else {
      createInvoice.mutate({ ticketId: ticket.id, ...payload }, { onSuccess, onError });
    }
  };

  return (
    <Dialog
      open
      onClose={onClose}
      title={existing.data ? `ویرایش فاکتور ${existing.data.invoiceNumber}` : 'صدور فاکتور'}
    >
      <div className="flex flex-col gap-3.5">
        {/* اطلاعات خودکار */}
        <div className="grid grid-cols-3 gap-2 rounded-md border border-border bg-background px-3.5 py-2.5">
          <div>
            <div className="text-[10.5px] text-muted-foreground">خریدار</div>
            <div className="text-[12.5px] font-bold">{ticket.customerName}</div>
          </div>
          <div>
            <div className="text-[10.5px] text-muted-foreground">شماره تماس</div>
            <div dir="ltr" className="text-right text-[12.5px] font-bold">
              {ticket.customerPhone}
            </div>
          </div>
          <div>
            <div className="text-[10.5px] text-muted-foreground">شماره پذیرش</div>
            <div className="text-[12.5px] font-bold">{ticket.ticketNumber}</div>
          </div>
        </div>

        {/* اقلام */}
        <div className="space-y-2">
          <Label>اقلام فاکتور</Label>
          {rows.map((row, index) => (
            <div key={row.key} className="rounded-md border border-border bg-background p-2.5">
              <div className="mb-2 flex items-center gap-2">
                <span className="text-[11px] font-bold text-muted-foreground">
                  ردیف {(index + 1).toLocaleString('fa-IR')}
                </span>
                <span className="mr-auto text-[11.5px] font-bold text-primary">
                  {(toNumber(row.quantity) * toNumber(row.unitPrice)).toLocaleString('fa-IR')} تومان
                </span>
                {rows.length > 1 && (
                  <button
                    type="button"
                    onClick={() => setRows((current) => current.filter((item) => item.key !== row.key))}
                    className="rounded-md p-1 text-destructive hover:bg-destructive/10"
                    aria-label="حذف ردیف"
                  >
                    <Trash2 className="h-3.5 w-3.5" />
                  </button>
                )}
              </div>

              <Input
                placeholder="شرح خدمات یا قطعه"
                value={row.title}
                onChange={(event) => updateRow(row.key, { title: event.target.value })}
              />

              <div className="mt-2 grid grid-cols-2 gap-2">
                <Input
                  inputMode="numeric"
                  placeholder="تعداد"
                  value={row.quantity}
                  onChange={(event) => updateRow(row.key, { quantity: event.target.value })}
                />
                <PriceInput
                  placeholder="قیمت واحد"
                  value={row.unitPrice}
                  onChange={(value) => updateRow(row.key, { unitPrice: value })}
                />
              </div>
            </div>
          ))}

          <button
            type="button"
            onClick={() => setRows((current) => [...current, emptyRow()])}
            className="flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed border-primary py-2.5 text-[12.5px] font-bold text-primary"
          >
            <Plus className="h-4 w-4" />
            افزودن ردیف
          </button>
        </div>

        {/* تخفیف */}
        <div className="space-y-2">
          <Label>تخفیف (اختیاری)</Label>
          <div className="flex gap-2">
            {([
              { value: 'NONE', label: 'بدون تخفیف' },
              { value: 'PERCENT', label: 'درصدی' },
              { value: 'AMOUNT', label: 'مبلغی' },
            ] as const).map((option) => (
              <button
                key={option.value}
                type="button"
                onClick={() => setDiscountType(option.value)}
                className={cn(
                  'flex-1 rounded-md border px-2 py-2.5 text-[12px] font-bold',
                  discountType === option.value
                    ? 'border-primary bg-accent text-accent-foreground'
                    : 'border-border bg-card text-muted-foreground',
                )}
              >
                {option.label}
              </button>
            ))}
          </div>
          {discountType !== 'NONE' && (
            <Input
              inputMode="numeric"
              dir="ltr"
              className="text-right"
              placeholder={discountType === 'PERCENT' ? 'درصد تخفیف' : 'مبلغ تخفیف (تومان)'}
              value={discountValue}
              onChange={(event) => setDiscountValue(event.target.value)}
            />
          )}
        </div>

        {/* جمع‌ها */}
        <div className="space-y-1.5 rounded-md border border-primary bg-accent px-3.5 py-3 text-accent-foreground">
          <div className="flex justify-between text-[12.5px]">
            <span>جمع کل</span>
            <span className="font-bold">{subtotal.toLocaleString('fa-IR')} تومان</span>
          </div>
          {discountAmount > 0 && (
            <div className="flex justify-between text-[12.5px]">
              <span>تخفیف</span>
              <span className="font-bold">{discountAmount.toLocaleString('fa-IR')} تومان</span>
            </div>
          )}
          <div className="flex justify-between border-t border-accent-foreground/20 pt-1.5 text-[14px] font-extrabold">
            <span>مبلغ قابل پرداخت</span>
            <span>{total.toLocaleString('fa-IR')} تومان</span>
          </div>
        </div>

        {/* توضیحات */}
        <div className="space-y-2.5">
          <Label>توضیحات فاکتور</Label>

          <div className="flex items-center gap-2">
            <Input
              inputMode="numeric"
              className="w-24"
              placeholder="مثلاً ۶"
              value={warrantyMonths}
              onChange={(event) => setWarrantyMonths(event.target.value)}
            />
            <span className="text-[12px] text-muted-foreground">
              ماه ضمانت (خالی = بند ضمانت چاپ نمی‌شود)
            </span>
          </div>

          <div className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-2.5">
            <Label htmlFor="batteryNote" className="text-[12px]">
              افزودن بند مخصوص تعویض باتری
            </Label>
            <Switch id="batteryNote" checked={hasBatteryNote} onCheckedChange={setHasBatteryNote} />
          </div>

          {extraNotes.map((note, index) => (
            <div key={index} className="flex gap-1.5">
              <Input
                placeholder="بند اضافی"
                value={note}
                onChange={(event) =>
                  setExtraNotes((current) =>
                    current.map((item, i) => (i === index ? event.target.value : item)),
                  )
                }
              />
              <button
                type="button"
                onClick={() => setExtraNotes((current) => current.filter((_, i) => i !== index))}
                className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md border border-border text-destructive"
                aria-label="حذف بند"
              >
                <Trash2 className="h-4 w-4" />
              </button>
            </div>
          ))}

          <button
            type="button"
            onClick={() => setExtraNotes((current) => [...current, ''])}
            className="flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed border-border py-2 text-[12px] font-bold text-muted-foreground"
          >
            <Plus className="h-3.5 w-3.5" />
            افزودن بند دلخواه
          </button>
        </div>

        <div className="flex gap-2">
          <Button variant="outline" disabled={isPending} onClick={() => handleSubmit(false)}>
            {isPending && <Loader2 className="h-4 w-4 animate-spin" />}
            ذخیره
          </Button>
          <Button disabled={isPending} onClick={() => handleSubmit(true)}>
            {isPending ? <Loader2 className="h-4 w-4 animate-spin" /> : <Printer className="h-4 w-4" />}
            ذخیره و چاپ
          </Button>
        </div>
      </div>
    </Dialog>
  );
}
