'use client';

import { useMemo, useState } from 'react';
import { Label } from '@/shared/components/ui/label';
import { Select } from '@/shared/components/ui/select';
import { useTaxonomy } from '@/features/part-requests/hooks/use-taxonomy';

type ModelCascadePickerProps = {
  isPublic?: boolean;
  onModelChange: (modelId: string) => void;
};

export function ModelCascadePicker({ isPublic = false, onModelChange }: ModelCascadePickerProps) {
  const taxonomy = useTaxonomy(isPublic);
  const [deviceTypeId, setDeviceTypeId] = useState('');
  const [brandId, setBrandId] = useState('');
  const [modelId, setModelId] = useState('');

  const filteredModels = useMemo(() => {
    if (!taxonomy.data || !brandId) return [];
    return taxonomy.data.models.filter(
      (model) =>
        model.brandId === brandId &&
        (!deviceTypeId || model.deviceTypeId === deviceTypeId || model.deviceTypeId === null),
    );
  }, [taxonomy.data, brandId, deviceTypeId]);

  const selectModel = (value: string) => {
    setModelId(value);
    onModelChange(value);
  };

  return (
    <div className="grid grid-cols-1 gap-2.5 sm:grid-cols-3">
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="cascadeDeviceType">نوع دستگاه</Label>
        <Select
          id="cascadeDeviceType"
          value={deviceTypeId}
          onChange={(event) => { setDeviceTypeId(event.target.value); selectModel(''); }}
        >
          <option value="">همه</option>
          {taxonomy.data?.deviceTypes.map((type) => (
            <option key={type.id} value={type.id}>{type.name}</option>
          ))}
        </Select>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="cascadeBrand">برند</Label>
        <Select
          id="cascadeBrand"
          value={brandId}
          onChange={(event) => { setBrandId(event.target.value); selectModel(''); }}
        >
          <option value="">انتخاب کنید…</option>
          {taxonomy.data?.brands.map((brand) => (
            <option key={brand.id} value={brand.id}>{brand.name}</option>
          ))}
        </Select>
      </div>
      <div className="flex flex-col gap-1.5">
        <Label htmlFor="cascadeModel">مدل</Label>
        <Select
          id="cascadeModel"
          value={modelId}
          disabled={!brandId}
          onChange={(event) => selectModel(event.target.value)}
        >
          <option value="">انتخاب کنید…</option>
          {filteredModels.map((model) => (
            <option key={model.id} value={model.id}>{model.name}</option>
          ))}
        </Select>
      </div>
    </div>
  );
}
