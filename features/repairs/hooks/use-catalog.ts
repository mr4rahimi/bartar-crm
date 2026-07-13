'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type CatalogBrand = {
  id: string;
  name: string;
  models: { id: string; name: string }[];
};

export function useCatalog() {
  return useQuery({
    queryKey: ['brands-catalog'],
    queryFn: () => apiFetch<CatalogBrand[]>('/api/v1/brands'),
  });
}
