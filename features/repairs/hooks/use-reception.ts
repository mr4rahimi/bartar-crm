'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { CustomerDto, TicketDto } from '../types/ticket.types';
import type { CustomerFormInput } from '../validators/customer.schema';
import type { CreateTicketFormInput } from '../validators/create-ticket.schema';

export type CatalogItem = { id: string; name: string };

export function useCustomerSearch(term: string) {
  return useQuery({
    queryKey: ['customers', term],
    enabled: term.trim().length >= 2,
    queryFn: () => apiFetch<CustomerDto[]>(`/api/v1/customers?search=${encodeURIComponent(term)}`),
  });
}

export function useCreateCustomer() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CustomerFormInput) =>
      apiFetch<CustomerDto>('/api/v1/customers', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['customers'] }),
  });
}

export function useReceptionCatalog(deviceTypeId: string) {
  return useQuery({
    queryKey: ['reception-catalog', deviceTypeId],
    queryFn: () =>
      apiFetch<{ accessories: CatalogItem[]; issues: CatalogItem[] }>(
        `/api/v1/reception-catalog${deviceTypeId ? `?deviceTypeId=${deviceTypeId}` : ''}`,
      ),
  });
}

export function useCreateCatalogItem(kind: 'accessories' | 'device-issues') {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: { name: string; deviceTypeId?: string }) =>
      apiFetch<CatalogItem>(`/api/v1/${kind}`, {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['reception-catalog'] }),
  });
}

export function useCreateTicket() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: CreateTicketFormInput) =>
      apiFetch<TicketDto>('/api/v1/repair-tickets', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['repair-tickets'] }),
  });
}
