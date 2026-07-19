'use client';

import { useState } from 'react';
import { Plus, Search } from 'lucide-react';
import { Input } from './input';
import { cn } from '@/shared/lib/cn';

type Item = { id: string; name: string };

type ChipMultiSelectProps = {
  items: Item[];
  selectedIds: string[];
  onToggle: (id: string) => void;
  onAdd: () => void;
  emptyText?: string;
  searchable?: boolean;
};

export function ChipMultiSelect({
  items,
  selectedIds,
  onToggle,
  onAdd,
  emptyText = 'موردی تعریف نشده',
  searchable = true,
}: ChipMultiSelectProps) {
  const [search, setSearch] = useState('');
  const term = search.trim();
  const filtered = term ? items.filter((item) => item.name.includes(term)) : items;

  return (
    <div className="space-y-2">
      {searchable && items.length > 8 && (
        <div className="relative">
          <Search className="absolute right-3 top-1/2 h-3.5 w-3.5 -translate-y-1/2 text-muted-foreground" />
          <Input
            className="h-9 pr-8 text-[12.5px]"
            placeholder="جستجو…"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
          />
        </div>
      )}

      <div className="flex max-h-48 flex-wrap gap-1.5 overflow-y-auto rounded-md border border-border bg-background p-2.5">
        {filtered.map((item) => {
          const isSelected = selectedIds.includes(item.id);
          return (
            <button
              key={item.id}
              type="button"
              onClick={() => onToggle(item.id)}
              className={cn(
                'rounded-full border px-3 py-1.5 text-[12px] font-semibold transition-colors',
                isSelected
                  ? 'border-primary bg-primary text-primary-foreground'
                  : 'border-border bg-card text-muted-foreground hover:border-primary/40',
              )}
            >
              {item.name}
            </button>
          );
        })}

        <button
          type="button"
          onClick={onAdd}
          className="flex items-center gap-1 rounded-full border border-dashed border-primary px-3 py-1.5 text-[12px] font-bold text-primary"
        >
          <Plus className="h-3.5 w-3.5" />
          جدید
        </button>

        {filtered.length === 0 && (
          <span className="px-1 py-1.5 text-[12px] text-muted-foreground">{emptyText}</span>
        )}
      </div>

      {selectedIds.length > 0 && (
        <p className="text-[11px] font-semibold text-muted-foreground">
          {selectedIds.length.toLocaleString('fa-IR')} مورد انتخاب شده
        </p>
      )}
    </div>
  );
}
