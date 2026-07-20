'use client';

import { useQuery } from '@tanstack/react-query';
import type { RepairTicketStatus } from '@prisma/client';
import { apiFetch } from '@/shared/lib/api-client';
import type { TicketDto } from '../types/ticket.types';
import type { TICKET_SORT_FIELDS } from '../validators/ticket-query.schema';

export type TicketSortField = (typeof TICKET_SORT_FIELDS)[number];

export type TicketListParams = {
  page: number;
  search?: string;
  status?: RepairTicketStatus;
  sortBy: TicketSortField;
  sortDir: 'asc' | 'desc';
  deleted?: boolean;
};

export type TicketListResult = {
  items: TicketDto[];
  total: number;
  page: number;
  pageSize: number;
};

export function useTickets(params: TicketListParams) {
  return useQuery({
    queryKey: ['repair-tickets', params],
    queryFn: () => {
      const query = new URLSearchParams({
        page: String(params.page),
        sortBy: params.sortBy,
        sortDir: params.sortDir,
      });
      if (params.search) query.set('search', params.search);
      if (params.status) query.set('status', params.status);
      if (params.deleted) query.set('deleted', 'true');

      return apiFetch<TicketListResult>(`/api/v1/repair-tickets?${query.toString()}`);
    },
  });
}

export function useTicket(ticketId: string, enabled = true) {
  return useQuery({
    queryKey: ['repair-ticket', ticketId],
    enabled,
    queryFn: () => apiFetch<TicketDto>(`/api/v1/repair-tickets/${ticketId}`),
  });
}
