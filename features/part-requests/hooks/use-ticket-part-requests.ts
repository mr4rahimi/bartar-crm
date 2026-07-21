'use client';

import { useQuery } from '@tanstack/react-query';
import type { PartRequestStatus } from '@prisma/client';
import { apiFetch } from '@/shared/lib/api-client';

export type TicketPartRequest = {
  id: string;
  partName: string;
  quantity: number;
  status: PartRequestStatus;
  announcedPrice: number | null;
  createdAt: string;
};

export function useTicketPartRequests(ticketId: string, enabled = true) {
  return useQuery({
    queryKey: ['ticket-part-requests', ticketId],
    enabled,
    queryFn: () =>
      apiFetch<TicketPartRequest[]>(`/api/v1/repair-tickets/${ticketId}/part-requests`),
  });
}
