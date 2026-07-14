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
