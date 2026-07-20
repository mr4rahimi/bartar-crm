'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { RepairTicketStatus } from '@prisma/client';
import type { TicketDto } from '../types/ticket.types';
import type { TicketAction } from '../constants/workflow.constants';

export type Technician = { id: string; name: string; phone: string };

export type StatusHistoryEntry = {
  id: string;
  previousStatus: RepairTicketStatus | null;
  newStatus: RepairTicketStatus;
  action: string;
  changedByName: string;
  description: string | null;
  createdAt: string;
};

export function useTechnicians(enabled: boolean) {
  return useQuery({
    queryKey: ['technicians'],
    enabled,
    queryFn: () => apiFetch<Technician[]>('/api/v1/technicians'),
  });
}

export function useTicketHistory(ticketId: string, enabled: boolean) {
  return useQuery({
    queryKey: ['ticket-history', ticketId],
    enabled,
    queryFn: () =>
      apiFetch<StatusHistoryEntry[]>(`/api/v1/repair-tickets/${ticketId}/history`),
  });
}

export function useApplyTicketAction() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      ticketId,
      ...body
    }: {
      ticketId: string;
      action: TicketAction;
      technicianId?: string;
      reason?: string;
    }) =>
      apiFetch<TicketDto>(`/api/v1/repair-tickets/${ticketId}/actions`, {
        method: 'POST',
        body: JSON.stringify(body),
      }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['repair-tickets'] });
      queryClient.invalidateQueries({ queryKey: ['repair-ticket'] });
      queryClient.invalidateQueries({ queryKey: ['ticket-history'] });
      queryClient.invalidateQueries({ queryKey: ['notifications'] });
    },
  });
}
