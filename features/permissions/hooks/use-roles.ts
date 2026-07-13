'use client';

import { useQuery } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { RoleDto } from '../types/role.types';

export function useRoles() {
  return useQuery({
    queryKey: ['roles'],
    queryFn: () => apiFetch<RoleDto[]>('/api/v1/roles'),
  });
}
