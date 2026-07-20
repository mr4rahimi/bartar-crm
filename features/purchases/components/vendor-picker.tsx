'use client';

import { useState } from 'react';
import { X } from 'lucide-react';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { useVendors } from '../hooks/use-purchases';

export type VendorSelection =
  | { kind: 'existing'; id: string; name: string }
  | { kind: 'new'; name: string; phone: string; landline: string }
  | null;

type VendorPickerProps = {
  value: VendorSelection;
  onChange: (value: VendorSelection) => void;
};

// انتخاب فروشنده با جستجوی زنده + ساخت سریع — بدون select بومی مرورگر
export function VendorPicker({ value, onChange }: VendorPickerProps) {
  const [search, setSearch] = useState('');
  const vendors = useVendors();

  if (value?.kind === 'existing') {
    return (
      <div className="flex items-center justify-between rounded-md border border-primary bg-accent px-3.5 py-3">
        <div className="text-[13px] font-bold text-accent-foreground">{value.name}</div>
        <button
          type="button"
          onClick={() => onChange(null)}
          className="rounded-md p-1 text-muted-foreground hover:bg-muted"
          aria-label="حذف انتخاب"
        >
          <X className="h-4 w-4" />
        </button>
      </div>
    );
  }

  if (value?.kind === 'new') {
    return (
      <div className="space-y-2.5 rounded-md border border-border bg-background p-3">
        <div className="flex items-center justify-between">
          <span className="text-xs font-bold text-muted-foreground">فروشنده جدید</span>
          <button
            type="button"
            onClick={() => onChange(null)}
            className="rounded-md p-1 text-muted-foreground hover:bg-muted"
            aria-label="انصراف"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <Input
          placeholder="نام فروشنده"
          value={value.name}
          onChange={(event) => onChange({ ...value, name: event.target.value })}
          autoFocus
        />

        <div className="grid grid-cols-2 gap-2">
          <Input
            dir="ltr"
            className="text-right"
            inputMode="numeric"
            placeholder="شماره همراه"
            value={value.phone}
            onChange={(event) => onChange({ ...value, phone: event.target.value })}
          />
          <Input
            dir="ltr"
            className="text-right"
            inputMode="numeric"
            placeholder="تلفن ثابت"
            value={value.landline}
            onChange={(event) => onChange({ ...value, landline: event.target.value })}
          />
        </div>

        <p className="text-[11px] text-muted-foreground">
          وارد کردن حداقل یکی از دو شماره الزامی است.
        </p>
      </div>
    );
  }

  const normalizedSearch = search.trim();
  const filtered = (vendors.data ?? []).filter(
    (vendor) => !normalizedSearch || vendor.name.includes(normalizedSearch),
  );

  return (
    <div className="flex flex-col gap-1.5">
      <Label>فروشنده</Label>
      <Input
        placeholder="جستجوی نام فروشنده…"
        value={search}
        onChange={(event) => setSearch(event.target.value)}
      />
      <div className="max-h-44 overflow-y-auto rounded-md border border-border bg-card">
        {filtered.map((vendor) => (
          <button
            key={vendor.id}
            type="button"
            onClick={() => onChange({ kind: 'existing', id: vendor.id, name: vendor.name })}
            className="block w-full border-b border-border px-3.5 py-2.5 text-right text-[13px] last:border-b-0 hover:bg-muted"
          >
            {vendor.name}
            {vendor.phone && (
              <span dir="ltr" className="mr-2 text-[11px] text-muted-foreground">
                {vendor.phone}
              </span>
            )}
          </button>
        ))}
        {filtered.length === 0 && normalizedSearch && (
          <p className="px-3.5 py-2.5 text-[12px] text-muted-foreground">فروشنده‌ای یافت نشد</p>
        )}
        <button
          type="button"
          onClick={() =>
            onChange({ kind: 'new', name: normalizedSearch, phone: '', landline: '' })
          }
          className="block w-full px-3.5 py-2.5 text-right text-[13px] font-bold text-primary hover:bg-muted"
        >
          + ساخت سریع فروشنده{normalizedSearch ? ` «${normalizedSearch}»` : ''}
        </button>
      </div>
    </div>
  );
}
