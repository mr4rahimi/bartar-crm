'use client';

import { useState } from 'react';
import { Select } from '@/shared/components/ui/select';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { CatalogCard } from './catalog-card';
import { useCatalog, useCatalogMutations } from '../hooks/use-catalog-admin';

export function CatalogView() {
  const catalog = useCatalog();
  const deviceTypeMutations = useCatalogMutations('device-types');
  const brandMutations = useCatalogMutations('brands-admin');
  const modelMutations = useCatalogMutations('models');
  const partMutations = useCatalogMutations('parts-admin');

  // فیلترها و انتخاب‌های افزودن مدل
  const [modelBrandId, setModelBrandId] = useState('');
  const [modelDeviceTypeId, setModelDeviceTypeId] = useState('');
  const [filterBrandId, setFilterBrandId] = useState('');

  if (catalog.isLoading || !catalog.data) {
    return (
      <div className="space-y-4">
        <Skeleton className="h-8 w-40" />
        <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
          {[1, 2, 3, 4].map((key) => <Skeleton key={key} className="h-64 w-full" />)}
        </div>
      </div>
    );
  }

  const { deviceTypes, brands, models, parts } = catalog.data;

  const visibleModels = filterBrandId
    ? models.filter((model) => model.brandId === filterBrandId)
    : models;

  const brandName = (brandId: string) => brands.find((b) => b.id === brandId)?.name ?? '';

  return (
    <div className="space-y-4">
      <div>
        <h1 className="text-xl font-extrabold">مدیریت کاتالوگ</h1>
        <p className="mt-1 text-[12.5px] text-muted-foreground">
          نوع دستگاه، برند، مدل و قطعه را مدیریت کنید. موارد دارای وابستگی قابل حذف نیستند.
        </p>
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <CatalogCard title="نوع دستگاه" items={deviceTypes} mutations={deviceTypeMutations} />

        <CatalogCard title="برند" items={brands} mutations={brandMutations} />

        <CatalogCard
          title="مدل"
          items={visibleModels.map((model) => ({
            id: model.id,
            name: `${brandName(model.brandId)} — ${model.name}`,
          }))}
          mutations={modelMutations}
          buildCreateBody={(name) => {
            if (!modelBrandId || !modelDeviceTypeId) return null;
            return { name, brandId: modelBrandId, deviceTypeId: modelDeviceTypeId };
          }}
          extraCreateFields={
            <div className="grid grid-cols-2 gap-2">
              <Select value={modelDeviceTypeId} onChange={(event) => setModelDeviceTypeId(event.target.value)}>
                <option value="">نوع دستگاه…</option>
                {deviceTypes.map((type) => (
                  <option key={type.id} value={type.id}>{type.name}</option>
                ))}
              </Select>
              <Select value={modelBrandId} onChange={(event) => setModelBrandId(event.target.value)}>
                <option value="">برند…</option>
                {brands.map((brand) => (
                  <option key={brand.id} value={brand.id}>{brand.name}</option>
                ))}
              </Select>
              <div className="col-span-2">
                <Select value={filterBrandId} onChange={(event) => setFilterBrandId(event.target.value)}>
                  <option value="">نمایش همه‌ی مدل‌ها</option>
                  {brands.map((brand) => (
                    <option key={brand.id} value={brand.id}>فقط {brand.name}</option>
                  ))}
                </Select>
              </div>
            </div>
          }
        />

        <CatalogCard title="قطعه" items={parts} mutations={partMutations} />
      </div>
    </div>
  );
}
