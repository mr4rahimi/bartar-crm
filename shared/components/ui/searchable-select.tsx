'use client';

import { useMemo, useState } from 'react';
import { Check, ChevronDown, Plus, Search, X } from 'lucide-react';
import { Input } from './input';
import { cn } from '@/shared/lib/cn';

export type SelectItem = { id: string; name: string; hint?: string };

type SearchableSelectProps = {
  items: SelectItem[];
  value: string;
  onChange: (id: string) => void;
  placeholder?: string;
  disabled?: boolean;
  emptyText?: string;
  /** در صورت وجود، گزینه‌ی «ثبت جدید» با متن جستجوشده نمایش داده می‌شود */
  onCreate?: (term: string) => void;
  createLabel?: string;
  isCreating?: boolean;
  id?: string;
};

export function SearchableSelect({
  items,
  value,
  onChange,
  placeholder = 'انتخاب کنید…',
  disabled = false,
  emptyText = 'موردی یافت نشد',
  onCreate,
  createLabel = 'ثبت جدید',
  isCreating = false,
  id,
}: SearchableSelectProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [search, setSearch] = useState('');

  const selected = items.find((item) => item.id === value);
  const term = search.trim();

  const filtered = useMemo(() => {
    if (!term) return items.slice(0, 60);
    return items.filter((item) => item.name.toLowerCase().includes(term.toLowerCase())).slice(0, 60);
  }, [items, term]);

  const hasExact = items.some((item) => item.name.trim() === term);

  if (!isOpen) {
    return (
      <button
        id={id}
        type="button"
        disabled={disabled}
        onClick={() => { setIsOpen(true); setSearch(''); }}
        className={cn(
          'flex h-11 w-full items-center justify-between rounded-md border border-input bg-background px-3 text-sm disabled:opacity-50',
          !selected && 'text-muted-foreground',
        )}
      >
        <span className="truncate">{selected?.name ?? placeholder}</span>
        <ChevronDown className="h-4 w-4 shrink-0 text-muted-foreground" />
      </button>
    );
  }

  return (
    <div className="rounded-md border border-primary bg-background p-2">
      <div className="relative">
        <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          className="h-10 pr-9"
          placeholder="جستجو…"
          value={search}
          onChange={(event) => setSearch(event.target.value)}
          autoFocus
        />
        <button
          type="button"
          onClick={() => setIsOpen(false)}
          className="absolute left-2 top-1/2 -translate-y-1/2 rounded-md p-1 text-muted-foreground hover:bg-muted"
          aria-label="بستن"
        >
          <X className="h-4 w-4" />
        </button>
      </div>

      <div className="mt-2 max-h-56 overflow-y-auto">
        {filtered.map((item) => (
          <button
            key={item.id}
            type="button"
            onClick={() => { onChange(item.id); setIsOpen(false); }}
            className="flex w-full items-center justify-between gap-2 rounded-md px-3 py-2.5 text-right text-[13px] hover:bg-muted"
          >
            <span className="truncate">
              {item.name}
              {item.hint && (
                <span className="mr-2 text-[11px] text-muted-foreground">{item.hint}</span>
              )}
            </span>
            {item.id === value && <Check className="h-4 w-4 shrink-0 text-primary" />}
          </button>
        ))}

        {filtered.length === 0 && !onCreate && (
          <p className="px-3 py-3 text-center text-[12.5px] text-muted-foreground">{emptyText}</p>
        )}
      </div>

      {onCreate && term && !hasExact && (
        <button
          type="button"
          disabled={isCreating}
          onClick={() => onCreate(term)}
          className="mt-1 flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed border-primary py-2.5 text-[12.5px] font-bold text-primary disabled:opacity-50"
        >
          <Plus className="h-4 w-4" />
          {createLabel} «{term}»
        </button>
      )}
    </div>
  );
}
