'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { UserDto } from '../types/user.types';
import type { CreateUserInput } from '../validators/create-user.schema';
import type { UpdateUserInput } from '../validators/update-user.schema';

export function useUserMutations() {
  const queryClient = useQueryClient();
  const invalidate = () => queryClient.invalidateQueries({ queryKey: ['users'] });

  const createUser = useMutation({
    mutationFn: (input: CreateUserInput) =>
      apiFetch<UserDto>('/api/v1/users', { method: 'POST', body: JSON.stringify(input) }),
    onSuccess: invalidate,
  });

  const updateUser = useMutation({
    mutationFn: ({ userId, input }: { userId: string; input: UpdateUserInput }) =>
      apiFetch<UserDto>(`/api/v1/users/${userId}`, {
        method: 'PATCH',
        body: JSON.stringify(input),
      }),
    onSuccess: invalidate,
  });

  const deleteUser = useMutation({
    mutationFn: (userId: string) =>
      apiFetch<null>(`/api/v1/users/${userId}`, { method: 'DELETE' }),
    onSuccess: invalidate,
  });

  return { createUser, updateUser, deleteUser };
}
