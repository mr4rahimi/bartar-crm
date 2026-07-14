'use client';

import { useState } from 'react';
import { Pencil, Search, Tag, TriangleAlert } from 'lucide-react';
import type { PartQuality } from '@prisma/client';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Select } from '@/shared/components/ui/select';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { useTaxonomy } from '@/features/part-requests/hooks/use-taxonomy';
import { usePriceList } from '../hooks/use-prices';
import type { PriceListRow } from '../types/price.types';

// ترتیب ستون‌ها مطابق price-next: کپی، های‌کپی (کپی۱)، اورجینال
const QUALITY_COLUMNS: { quality: PartQuality; label: string }[] = [
  { quality: 'COPY', label: 'کپی' },
  { quality: 'HIGH_COPY', label: 'های‌کپی' },
  { quality: 'ORIGINAL', label: 'اورجینال' },
];

function PriceCell({ value }: { value: number | null | undefined }) {
  if (value === null || value === undefined) {
    return <span className="text-[11px] text-muted-foreground">ناموجود</span>;
  }
  return (
    <span className="font-extrabold text-[#15803d] dark:text-[#4ade80]">
      {value.toLocaleString('fa-IR')} <span className="text-[10px] font-normal text-muted-foreground">ت</span>
    </span>
  );
}

type PriceListViewProps = {
  isPublic: boolean;
  showBuy?: boolean;
  onEdit?: (row: PriceListRow) => void;
  onHistory?: (row: PriceListRow) => void;
};

export function PriceListView({ isPublic, showBuy = false, onEdit, onHistory }: PriceListViewProps) {
  const [search, setSearch] = useState('');
  const [deviceTypeId, setDeviceTypeId] = useState('');
  const [brandId, setBrandId] = useState('');
  const [partId, setPartId] = useState('');
  const [page, setPage] = useState(1);

  const debouncedSearch = useDebouncedValue(search, 300);
  const taxonomy = useTaxonomy(isPublic);

  const query = usePriceList(
    {
      page,
      search: debouncedSearch || undefined,
      deviceTypeId: deviceTypeId || undefined,
      brandId: brandId || undefined,
      partId: partId || undefined,
    },
    isPublic,
  );

  const totalPages = query.data ? Math.max(1, Math.ceil(query.data.total / query.data.pageSize)) : 1;

  const resetPage = () => setPage(1);

  return (
    <div className="space-y-3">
      <div className="space-y-2.5 rounded-lg border border-border bg-card p-3.5">
        <div className="relative">
          <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            className="pr-9"
            placeholder="جستجو در نام مدل، برند یا قطعه…"
            value={search}
            onChange={(event) => { setSearch(event.target.value); resetPage(); }}
          />
        </div>
        <div className="grid grid-cols-3 gap-2">
          <Select value={deviceTypeId} onChange={(event) => { setDeviceTypeId(event.target.value); resetPage(); }}>
            <option value="">همه دستگاه‌ها</option>
            {taxonomy.data?.deviceTypes.map((type) => (
              <option key={type.id} value={type.id}>{type.name}</option>
            ))}
          </Select>
          <Select value={brandId} onChange={(event) => { setBrandId(event.target.value); resetPage(); }}>
            <option value="">همه برندها</option>
            {taxonomy.data?.brands.map((brand) => (
              <option key={brand.id} value={brand.id}>{brand.name}</option>
            ))}
          </Select>
          <Select value={partId} onChange={(event) => { setPartId(event.target.value); resetPage(); }}>
            <option value="">همه قطعات</option>
            {taxonomy.data?.parts.map((part) => (
              <option key={part.id} value={part.id}>{part.name}</option>
            ))}
          </Select>
        </div>
      </div>

      {query.isLoading && (
        <div className="space-y-2">
          {[1, 2, 3, 4].map((key) => <Skeleton key={key} className="h-24 w-full" />)}
        </div>
      )}

      {query.data && (
        <div className="text-[11.5px] font-semibold text-muted-foreground">
          {query.data.total.toLocaleString('fa-IR')} نتیجه
        </div>
      )}

      {query.data?.items.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12">
          <Tag className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">موردی یافت نشد</p>
        </div>
      )}

      <div className="space-y-2">
        {query.data?.items.map((row) => {
          const hasReview = QUALITY_COLUMNS.some((c) => row.prices[c.quality]?.needsReview);
          return (
            <div key={`${row.modelId}-${row.partId}`} className="rounded-lg border border-border bg-card p-3.5">
              <div className="flex items-start justify-between gap-2">
                <div>
                  <div className="flex flex-wrap items-center gap-1.5">
                    {row.deviceTypeName && (
                      <span className="rounded-md bg-accent px-2 py-0.5 text-[10.5px] font-bold text-accent-foreground">
                        {row.deviceTypeName}
                      </span>
                    )}
                    <span className="text-[13.5px] font-extrabold">
                      {row.brandName} {row.modelName}
                    </span>
                    {hasReview && (
                      <TriangleAlert className="h-3.5 w-3.5 text-[#c2410c] dark:text-[#fb923c]" />
                    )}
                  </div>
                  <span className="mt-1 inline-block rounded-md bg-muted px-2 py-0.5 text-[11px] font-bold text-muted-foreground">
                    {row.partName}
                  </span>
                </div>
                <div className="flex shrink-0 gap-1">
                  {onHistory && (
                    <button
                      type="button"
                      onClick={() => onHistory(row)}
                      className="rounded-md px-2 py-1 text-[11px] font-bold text-primary hover:bg-muted"
                    >
                      تاریخچه
                    </button>
                  )}
                  {onEdit && (
                    <button
                      type="button"
                      onClick={() => onEdit(row)}
                      className="rounded-md p-1.5 text-muted-foreground hover:bg-muted"
                      aria-label="ویرایش"
                    >
                      <Pencil className="h-4 w-4" />
                    </button>
                  )}
                </div>
              </div>

              <div className="mt-2.5 grid grid-cols-3 gap-2">
                {QUALITY_COLUMNS.map(({ quality, label }) => {
                  const price = row.prices[quality];
                  return (
                    <div key={quality} className="rounded-md border border-border bg-background p-2.5 text-right">
                      <div className="text-[10.5px] font-bold text-muted-foreground">{label}</div>
                      <div className="mt-0.5 text-[12.5px]">
                        <PriceCell value={price?.sellPrice} />
                      </div>
                      {showBuy && (
                        <div className="mt-0.5 text-[10px] text-muted-foreground">
                          خرید: {price?.buyPrice != null ? price.buyPrice.toLocaleString('fa-IR') : '—'}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>

              <div className="mt-2 text-left text-[10.5px] text-muted-foreground">
                بروزرسانی: {new Date(row.updatedAt).toLocaleDateString('fa-IR')}
              </div>
            </div>
          );
        })}
      </div>

      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-3 text-sm">
          <Button variant="outline" className="h-9 w-auto px-4 text-xs" disabled={page <= 1}
            onClick={() => setPage((current) => current - 1)}>
            قبلی
          </Button>
          <span className="font-semibold text-muted-foreground">صفحه {page} از {totalPages}</span>
          <Button variant="outline" className="h-9 w-auto px-4 text-xs" disabled={page >= totalPages}
            onClick={() => setPage((current) => current + 1)}>
            بعدی
          </Button>
        </div>
      )}
    </div>
  );
}
