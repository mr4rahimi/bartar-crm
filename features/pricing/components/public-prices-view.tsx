'use client';

import { PriceListView } from './price-list-view';

export function PublicPricesView() {
  return (
    <div className="space-y-4">
      <PriceListView isPublic />
      <p className="text-center text-[11px] text-muted-foreground">
        قیمت‌ها بر اساس آخرین خریدها به‌روزرسانی می‌شوند و ممکن است تغییر کنند.
      </p>
    </div>
  );
}
