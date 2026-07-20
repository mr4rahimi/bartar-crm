'use client';

import { useMutation, useQuery, useQueryClient, keepPreviousData } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { PartRequestDto } from '@/features/part-requests/types/part-request.types';
import type { PurchaseDto, VendorDto } from '../types/purchase.types';
import type { AutoPricingResult } from '@/features/pricing/services/pricing.service';

type QueueResult = { items: PartRequestDto[]; total: number; page: number; pageSize: number };

/** صف خرید = درخواست‌های WAITING_PURCHASE / PURCHASING (همان REST درخواست‌ها) */
export function usePurchaseQueue(status: 'WAITING_PURCHASE' | 'PURCHASING', page: number) {
  return useQuery({
    queryKey: ['purchase-queue', status, page],
    placeholderData: keepPreviousData,
    queryFn: () =>
      apiFetch<QueueResult>(`/api/v1/part-requests?page=${page}&status=${status}`),
  });
}

type PurchasesResult = { items: PurchaseDto[]; total: number; page: number; pageSize: number };

export function usePurchases(page: number) {
  return useQuery({
    queryKey: ['purchases', page],
    placeholderData: keepPreviousData,
    queryFn: () => apiFetch<PurchasesResult>(`/api/v1/purchases?page=${page}`),
  });
}

export function useVendors() {
  return useQuery({
    queryKey: ['vendors'],
    queryFn: () => apiFetch<VendorDto[]>('/api/v1/vendors'),
  });
}

function useInvalidatePurchasing() {
  const queryClient = useQueryClient();
  return () => {
    queryClient.invalidateQueries({ queryKey: ['purchase-queue'] });
    queryClient.invalidateQueries({ queryKey: ['purchases'] });
    queryClient.invalidateQueries({ queryKey: ['part-requests'] });
    // Auto-Pricing قیمت‌ها را تغییر می‌دهد — لیست قیمت و بنر بازبینی هم تازه شوند
    queryClient.invalidateQueries({ queryKey: ['price-list'] });
    queryClient.invalidateQueries({ queryKey: ['prices-review'] });
  };
}

export function useRegisterPurchase() {
  const invalidate = useInvalidatePurchasing();

  return useMutation({
    mutationFn: (input: {
      partRequestId: string;
      vendorId?: string;
      newVendor?: { name: string; phone?: string; landline?: string };
      price: string | number;
      description?: string;
    }) =>
      apiFetch<{ purchase: PurchaseDto; pricing: AutoPricingResult }>('/api/v1/purchases', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: invalidate,
  });
}

export function useReturnPurchase() {
  const invalidate = useInvalidatePurchasing();

  return useMutation({
    mutationFn: ({ purchaseId, reason }: { purchaseId: string; reason: string }) =>
      apiFetch<PurchaseDto>(`/api/v1/purchases/${purchaseId}/return`, {
        method: 'POST',
        body: JSON.stringify({ reason }),
      }),
    onSuccess: invalidate,
  });
}

/** اکشن‌های صف (شروع خرید / عدم موجودی) — همان REST اکشن‌های درخواست */
export function useQueueAction() {
  const invalidate = useInvalidatePurchasing();

  return useMutation({
    mutationFn: ({
      requestId,
      action,
      description,
    }: {
      requestId: string;
      action: 'START_PURCHASE' | 'MARK_NOT_FOUND';
      description?: string;
    }) =>
      apiFetch(`/api/v1/part-requests/${requestId}/actions`, {
        method: 'POST',
        body: JSON.stringify({ action, description }),
      }),
    onSuccess: invalidate,
  });
}
