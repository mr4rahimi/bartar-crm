'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { TicketDto } from '../types/ticket.types';

type MyRepairsResult = {
  items: TicketDto[];
  total: number;
  page: number;
  pageSize: number;
};

export function useMyRepairs(status?: 'ASSIGNED' | 'IN_PROGRESS') {
  return useQuery({
    queryKey: ['my-repairs', status ?? 'all'],
    queryFn: () =>
      apiFetch<MyRepairsResult>(`/api/v1/my-repairs${status ? `?status=${status}` : ''}`),
    refetchInterval: 60_000,
  });
}
