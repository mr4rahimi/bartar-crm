'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type CatalogData = {
  deviceTypes: { id: string; name: string }[];
  brands: { id: string; name: string }[];
  models: { id: string; name: string; brandId: string; deviceTypeId: string | null }[];
  parts: { id: string; name: string }[];
};

export function useCatalog() {
  return useQuery({
    queryKey: ['catalog'],
    queryFn: () => apiFetch<CatalogData>('/api/v1/catalog'),
  });
}

function useCatalogInvalidate() {
  const queryClient = useQueryClient();
  return () => {
    queryClient.invalidateQueries({ queryKey: ['catalog'] });
    queryClient.invalidateQueries({ queryKey: ['taxonomy'] });
  };
}

type Entity = 'device-types' | 'brands-admin' | 'models' | 'parts-admin';

export function useCatalogMutations(entity: Entity) {
  const invalidate = useCatalogInvalidate();

  const create = useMutation({
    mutationFn: (body: Record<string, unknown>) =>
      apiFetch(`/api/v1/${entity}`, { method: 'POST', body: JSON.stringify(body) }),
    onSuccess: invalidate,
  });

  const update = useMutation({
    mutationFn: ({ id, name }: { id: string; name: string }) =>
      apiFetch(`/api/v1/${entity}/${id}`, { method: 'PATCH', body: JSON.stringify({ name }) }),
    onSuccess: invalidate,
  });

  const remove = useMutation({
    mutationFn: (id: string) => apiFetch(`/api/v1/${entity}/${id}`, { method: 'DELETE' }),
    onSuccess: invalidate,
  });

  return { create, update, remove };
}
