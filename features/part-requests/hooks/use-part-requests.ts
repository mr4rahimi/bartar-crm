'use client';

import { useQuery, keepPreviousData } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { PartRequestDto, PartRequestDetailDto } from '../types/part-request.types';

type ListParams = { page: number; search?: string; status?: string };

type ListResult = { items: PartRequestDto[]; total: number; page: number; pageSize: number };

export function usePartRequests(params: ListParams) {
  return useQuery({
    queryKey: ['part-requests', params],
    placeholderData: keepPreviousData,
    queryFn: () => {
      const searchParams = new URLSearchParams({ page: String(params.page) });
      if (params.search) searchParams.set('search', params.search);
      if (params.status) searchParams.set('status', params.status);
      return apiFetch<ListResult>(`/api/v1/part-requests?${searchParams.toString()}`);
    },
  });
}

export function usePartRequest(requestId: string) {
  return useQuery({
    queryKey: ['part-requests', 'detail', requestId],
    queryFn: () => apiFetch<PartRequestDetailDto>(`/api/v1/part-requests/${requestId}`),
  });
}

export function usePartOptions() {
  return useQuery({
    queryKey: ['parts'],
    queryFn: () => apiFetch<{ id: string; name: string }[]>('/api/v1/parts'),
  });
}
