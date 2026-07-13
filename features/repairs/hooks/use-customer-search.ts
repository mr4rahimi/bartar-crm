'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { CustomerDto } from '../types/ticket.types';

export function useCustomerSearch(search: string) {
  return useQuery({
    queryKey: ['customers', search],
    enabled: search.trim().length >= 2,
    queryFn: () =>
      apiFetch<CustomerDto[]>(`/api/v1/customers?search=${encodeURIComponent(search)}`),
  });
}
