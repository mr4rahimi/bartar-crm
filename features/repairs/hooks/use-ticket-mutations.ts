'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { TicketDto } from '../types/ticket.types';
import type { CreateTicketInput } from '../validators/create-ticket.schema';

export function useCreateTicket() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: CreateTicketInput) =>
      apiFetch<TicketDto>('/api/v1/repair-tickets', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['repair-tickets'] }),
  });
}
