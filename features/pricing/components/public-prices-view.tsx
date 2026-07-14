'use client';

import { useState } from 'react';
import { ModelCascadePicker } from './model-cascade-picker';
import { PriceTable } from './price-table';
import { useModelPrices } from '../hooks/use-prices';

export function PublicPricesView() {
  const [modelId, setModelId] = useState('');
  const prices = useModelPrices(modelId, true);

  return (
    <div className="space-y-4">
      <ModelCascadePicker isPublic onModelChange={setModelId} />
      {modelId ? (
        <PriceTable rows={prices.data} isLoading={prices.isLoading} showBuy={false} />
      ) : (
        <p className="rounded-lg border border-border bg-card py-10 text-center text-sm font-semibold text-muted-foreground">
          برای مشاهده قیمت‌ها، دستگاه و مدل را انتخاب کنید
        </p>
      )}
      <p className="text-center text-[11px] text-muted-foreground">
        قیمت‌ها بر اساس آخرین خریدها به‌روزرسانی می‌شوند و ممکن است تغییر کنند.
      </p>
    </div>
  );
}
