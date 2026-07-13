'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type PermissionDto = {
  id: string;
  code: string;
  group: string;
  description: string | null;
};

export function usePermissions() {
  return useQuery({
    queryKey: ['permissions'],
    queryFn: () => apiFetch<PermissionDto[]>('/api/v1/permissions'),
  });
}
