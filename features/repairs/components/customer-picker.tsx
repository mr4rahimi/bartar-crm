'use client';

import { useState } from 'react';
import { X } from 'lucide-react';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { useCustomerSearch } from '../hooks/use-customer-search';
import type { CustomerDto } from '../types/ticket.types';

export type CustomerSelection =
  | { kind: 'existing'; customer: CustomerDto }
  | { kind: 'new'; name: string; phone: string }
  | null;

type CustomerPickerProps = {
  value: CustomerSelection;
  onChange: (value: CustomerSelection) => void;
};

// جستجوی مشتری + گزینه‌ی «ساخت سریع» — مطابق ماکاپ ui/
export function CustomerPicker({ value, onChange }: CustomerPickerProps) {
  const [search, setSearch] = useState('');
  const debouncedSearch = useDebouncedValue(search);
  const results = useCustomerSearch(debouncedSearch);

  if (value?.kind === 'existing') {
    return (
      <div className="flex items-center justify-between rounded-md border border-primary bg-accent px-3.5 py-3">
        <div>
          <div className="text-[13px] font-bold text-accent-foreground">
            {value.customer.name}
          </div>
          <div dir="ltr" className="text-right text-[11.5px] text-muted-foreground">
            {value.customer.phone}
          </div>
        </div>
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
          <span className="text-xs font-bold text-muted-foreground">مشتری جدید</span>
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
          placeholder="نام مشتری"
          value={value.name}
          onChange={(event) => onChange({ ...value, name: event.target.value })}
        />
        <Input
          dir="ltr"
          className="text-right"
          placeholder="09xxxxxxxxx"
          value={value.phone}
          onChange={(event) => onChange({ ...value, phone: event.target.value })}
        />
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-1.5">
      <Label>مشتری</Label>
      <Input
        placeholder="جستجوی نام یا موبایل…"
        value={search}
        onChange={(event) => setSearch(event.target.value)}
      />
      {search.trim().length >= 2 && (
        <div className="overflow-hidden rounded-md border border-border bg-card">
          {results.data?.map((customer) => (
            <button
              key={customer.id}
              type="button"
              onClick={() => onChange({ kind: 'existing', customer })}
              className="block w-full border-b border-border px-3.5 py-2.5 text-right text-[13px] hover:bg-muted"
            >
              {customer.name} — <span dir="ltr">{customer.phone}</span>
            </button>
          ))}
          <button
            type="button"
            onClick={() => onChange({ kind: 'new', name: search.trim(), phone: '' })}
            className="block w-full px-3.5 py-2.5 text-right text-[13px] font-bold text-primary hover:bg-muted"
          >
            + ساخت سریع مشتری «{search.trim()}»
          </button>
        </div>
      )}
    </div>
  );
}
