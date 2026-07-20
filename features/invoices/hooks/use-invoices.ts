'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { InvoiceDto } from '../types/invoice.types';
import type { InvoiceFormInput } from '../validators/invoice.schema';

export function useInvoiceByTicket(ticketId: string | null) {
  return useQuery({
    queryKey: ['invoice-by-ticket', ticketId],
    enabled: Boolean(ticketId),
    queryFn: () => apiFetch<InvoiceDto | null>(`/api/v1/invoices/by-ticket/${ticketId}`),
  });
}

function useInvalidate() {
  const queryClient = useQueryClient();
  return () => {
    queryClient.invalidateQueries({ queryKey: ['invoice-by-ticket'] });
    queryClient.invalidateQueries({ queryKey: ['repair-tickets'] });
  };
}

export function useCreateInvoice() {
  const invalidate = useInvalidate();
  return useMutation({
    mutationFn: (input: InvoiceFormInput) =>
      apiFetch<InvoiceDto>('/api/v1/invoices', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: invalidate,
  });
}

export function useUpdateInvoice() {
  const invalidate = useInvalidate();
  return useMutation({
    mutationFn: ({ invoiceId, ...input }: { invoiceId: string } & Omit<InvoiceFormInput, 'ticketId'>) =>
      apiFetch<InvoiceDto>(`/api/v1/invoices/${invoiceId}`, {
        method: 'PATCH',
        body: JSON.stringify(input),
      }),
    onSuccess: invalidate,
  });
}
