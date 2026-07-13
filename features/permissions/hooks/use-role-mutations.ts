'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { RoleDto } from '../types/role.types';
import type { CreateRoleInput, UpdateRoleInput } from '../validators/role.schema';

export function useRoleMutations() {
  const queryClient = useQueryClient();
  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['roles'] });

  const createRole = useMutation({
    mutationFn: (input: CreateRoleInput) =>
      apiFetch<RoleDto>('/api/v1/roles', { method: 'POST', body: JSON.stringify(input) }),
    onSuccess: invalidate,
  });

  const updateRole = useMutation({
    mutationFn: ({ roleId, input }: { roleId: string; input: UpdateRoleInput }) =>
      apiFetch<RoleDto>(`/api/v1/roles/${roleId}`, {
        method: 'PATCH',
        body: JSON.stringify(input),
      }),
    onSuccess: invalidate,
  });

  const deleteRole = useMutation({
    mutationFn: (roleId: string) =>
      apiFetch<null>(`/api/v1/roles/${roleId}`, { method: 'DELETE' }),
    onSuccess: invalidate,
  });

  return { createRole, updateRole, deleteRole };
}
