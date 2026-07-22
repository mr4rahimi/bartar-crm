'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type QualityCheckDto = {
  id: string;
  notes: string;
  passed: boolean;
  checkedByName: string;
  createdAt: string;
};

export function useQualityChecks(ticketId: string, enabled = true) {
  return useQuery({
    queryKey: ['quality-checks', ticketId],
    enabled,
    queryFn: () =>
      apiFetch<QualityCheckDto[]>(`/api/v1/repair-tickets/${ticketId}/quality-checks`),
  });
}
