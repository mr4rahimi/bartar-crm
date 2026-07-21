'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

export type RepairNote = {
  id: string;
  body: string;
  authorName: string;
  createdAt: string;
};

export function useRepairNotes(ticketId: string, enabled = true) {
  return useQuery({
    queryKey: ['repair-notes', ticketId],
    enabled,
    queryFn: () => apiFetch<RepairNote[]>(`/api/v1/repair-tickets/${ticketId}/notes`),
  });
}

export function useAddRepairNote(ticketId: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: string) =>
      apiFetch<RepairNote>(`/api/v1/repair-tickets/${ticketId}/notes`, {
        method: 'POST',
        body: JSON.stringify({ body }),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['repair-notes', ticketId] }),
  });
}
