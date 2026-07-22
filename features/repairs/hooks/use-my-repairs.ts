'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { TicketDto } from '../types/ticket.types';

export type MyRepairsTab =
  | 'ASSIGNED'
  | 'IN_PROGRESS'
  | 'QUALITY_CHECK'
  | 'HANDOVER'
  | 'HISTORY';

type MyRepairsResult = {
  items: TicketDto[];
  total: number;
  page: number;
  pageSize: number;
};

export function useMyRepairs(tab: MyRepairsTab, enabled = true) {
  return useQuery({
    queryKey: ['my-repairs', tab],
    enabled,
    queryFn: () => apiFetch<MyRepairsResult>(`/api/v1/my-repairs?tab=${tab}`),
    refetchInterval: 60_000,
  });
}
