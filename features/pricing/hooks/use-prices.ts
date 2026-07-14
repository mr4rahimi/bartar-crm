'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { ModelPriceRow, ReviewItem, PriceHistoryItem } from '../types/price.types';
import type { SetPriceInput } from '../validators/set-price.schema';

export function useModelPrices(modelId: string, isPublic = false) {
  return useQuery({
    queryKey: ['prices', modelId, isPublic],
    enabled: Boolean(modelId),
    queryFn: () =>
      apiFetch<ModelPriceRow[]>(
        `${isPublic ? '/api/v1/public/prices' : '/api/v1/prices'}?modelId=${modelId}`,
      ),
  });
}

export function useNeedsReview(enabled: boolean) {
  return useQuery({
    queryKey: ['prices-review'],
    enabled,
    queryFn: () => apiFetch<ReviewItem[]>('/api/v1/prices/review'),
  });
}

export function useSetPrice() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: SetPriceInput | Record<string, unknown>) =>
      apiFetch<null>('/api/v1/prices', { method: 'PUT', body: JSON.stringify(input) }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['prices'] });
      queryClient.invalidateQueries({ queryKey: ['prices-review'] });
    },
  });
}

export function usePriceHistory(modelId: string | null, partId: string | null) {
  return useQuery({
    queryKey: ['price-history', modelId, partId],
    enabled: Boolean(modelId && partId),
    queryFn: () =>
      apiFetch<PriceHistoryItem[]>(`/api/v1/prices/history?modelId=${modelId}&partId=${partId}`),
  });
}

export type PriceListFilters = {
  page: number;
  search?: string;
  deviceTypeId?: string;
  brandId?: string;
  partId?: string;
};

export function usePriceList(filters: PriceListFilters, isPublic: boolean) {
  return useQuery({
    queryKey: ['price-list', filters, isPublic],
    placeholderData: (previous) => previous,
    queryFn: () => {
      const params = new URLSearchParams({ page: String(filters.page) });
      if (filters.search) params.set('search', filters.search);
      if (filters.deviceTypeId) params.set('deviceTypeId', filters.deviceTypeId);
      if (filters.brandId) params.set('brandId', filters.brandId);
      if (filters.partId) params.set('partId', filters.partId);
      const base = isPublic ? '/api/v1/public/price-list' : '/api/v1/price-list';
      return apiFetch<{
        items: import('../types/price.types').PriceListRow[];
        total: number;
        page: number;
        pageSize: number;
      }>(`${base}?${params.toString()}`);
    },
  });
}
