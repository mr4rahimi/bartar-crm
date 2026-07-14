'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type TaxonomyModel = {
  id: string;
  name: string;
  brandId: string;
  deviceTypeId: string | null;
};

export type Taxonomy = {
  deviceTypes: { id: string; name: string }[];
  brands: { id: string; name: string }[];
  models: TaxonomyModel[];
};

export function useTaxonomy() {
  return useQuery({
    queryKey: ['taxonomy'],
    queryFn: () => apiFetch<Taxonomy>('/api/v1/taxonomy'),
  });
}

export function useCreateModel() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: { name: string; deviceTypeId: string; brandId: string }) =>
      apiFetch<TaxonomyModel>('/api/v1/models', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['taxonomy'] }),
  });
}
