'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { TicketDto } from '../types/ticket.types';
import type { UpdateTicketFormInput } from '../validators/update-ticket.schema';

function useInvalidateTickets() {
  const queryClient = useQueryClient();
  return () => {
    queryClient.invalidateQueries({ queryKey: ['repair-tickets'] });
    queryClient.invalidateQueries({ queryKey: ['repair-ticket'] });
  };
}

export function useUpdateTicket() {
  const invalidate = useInvalidateTickets();

  return useMutation({
    mutationFn: ({ ticketId, ...input }: { ticketId: string } & UpdateTicketFormInput) =>
      apiFetch<TicketDto>(`/api/v1/repair-tickets/${ticketId}`, {
        method: 'PATCH',
        body: JSON.stringify(input),
      }),
    onSuccess: invalidate,
  });
}

export function useDeleteTicket() {
  const invalidate = useInvalidateTickets();

  return useMutation({
    mutationFn: (ticketId: string) =>
      apiFetch<null>(`/api/v1/repair-tickets/${ticketId}`, { method: 'DELETE' }),
    onSuccess: invalidate,
  });
}

export function useRestoreTicket() {
  const invalidate = useInvalidateTickets();

  return useMutation({
    mutationFn: (ticketId: string) =>
      apiFetch<TicketDto>(`/api/v1/repair-tickets/${ticketId}/restore`, { method: 'POST' }),
    onSuccess: invalidate,
  });
}
