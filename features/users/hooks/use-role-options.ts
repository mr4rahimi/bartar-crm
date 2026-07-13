'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

type RoleOption = { id: string; name: string };

export function useRoleOptions() {
  return useQuery({
    queryKey: ['roles'],
    queryFn: () => apiFetch<RoleOption[]>('/api/v1/roles'),
    select: (roles) => roles.map((role) => ({ id: role.id, name: role.name })),
  });
}
