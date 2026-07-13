'use client';

import { useQuery, keepPreviousData } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { UserDto } from '../types/user.types';

type UsersListParams = {
  page: number;
  search?: string;
  isActive?: 'true' | 'false';
};

type UsersListResult = {
  items: UserDto[];
  total: number;
  page: number;
  pageSize: number;
};

export function useUsers(params: UsersListParams) {
  return useQuery({
    queryKey: ['users', params],
    placeholderData: keepPreviousData,
    queryFn: () => {
      const searchParams = new URLSearchParams({ page: String(params.page) });
      if (params.search) searchParams.set('search', params.search);
      if (params.isActive) searchParams.set('isActive', params.isActive);
      return apiFetch<UsersListResult>(`/api/v1/users?${searchParams.toString()}`);
    },
  });
}
