'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type EntityLog = {
  id: string;
  action: string;
  userName: string;
  previousValue: Record<string, unknown> | null;
  newValue: Record<string, unknown> | null;
  createdAt: string;
};

export function useEntityLogs(entityType: string, entityId: string, enabled: boolean) {
  return useQuery({
    queryKey: ['activity-logs', entityType, entityId],
    enabled,
    queryFn: () =>
      apiFetch<EntityLog[]>(
        `/api/v1/activity-logs?entityType=${entityType}&entityId=${entityId}`,
      ),
  });
}
