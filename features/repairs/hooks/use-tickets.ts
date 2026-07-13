'use client';

import { useQuery, keepPreviousData } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { TicketDto } from '../types/ticket.types';

type TicketsListParams = {
  page: number;
  search?: string;
  status?: string;
};

type TicketsListResult = {
  items: TicketDto[];
  total: number;
  page: number;
  pageSize: number;
};

export function useTickets(params: TicketsListParams) {
  return useQuery({
    queryKey: ['repair-tickets', params],
    placeholderData: keepPreviousData,
    queryFn: () => {
      const searchParams = new URLSearchParams({ page: String(params.page) });
      if (params.search) searchParams.set('search', params.search);
      if (params.status) searchParams.set('status', params.status);
      return apiFetch<TicketsListResult>(`/api/v1/repair-tickets?${searchParams.toString()}`);
    },
  });
}
