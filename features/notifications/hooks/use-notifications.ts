'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type InboxItem = {
  id: string;
  title: string;
  message: string;
  isRead: boolean;
  entityType: string;
  entityId: string;
  createdAt: string;
};

export type Inbox = { unread: number; items: InboxItem[] };

export function useInbox() {
  return useQuery({
    queryKey: ['notifications'],
    queryFn: () => apiFetch<Inbox>('/api/v1/notifications'),
    refetchInterval: 60_000,
  });
}

export function useMarkRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) =>
      apiFetch<null>(`/api/v1/notifications/${id}/read`, { method: 'POST' }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['notifications'] }),
  });
}

export function useMarkAllRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => apiFetch<null>('/api/v1/notifications/read-all', { method: 'POST' }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['notifications'] }),
  });
}
