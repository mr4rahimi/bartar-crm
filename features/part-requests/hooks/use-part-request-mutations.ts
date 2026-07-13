'use client';

import { useMutation, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { PartRequestDetailDto } from '../types/part-request.types';
import type { CreatePartRequestInput } from '../validators/create-part-request.schema';
import type { PartRequestAction } from '../constants/state-machine.constants';

export function useCreatePartRequest() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (input: CreatePartRequestInput) =>
      apiFetch<PartRequestDetailDto>('/api/v1/part-requests', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['part-requests'] }),
  });
}

export type ApplyActionInput = {
  requestId: string;
  action: PartRequestAction;
  price?: number | string;
  description?: string;
};

export function useApplyPartRequestAction() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ requestId, ...input }: ApplyActionInput) =>
      apiFetch<PartRequestDetailDto>(`/api/v1/part-requests/${requestId}/actions`, {
        method: 'POST',
        body: JSON.stringify(input),
      }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['part-requests'] }),
  });
}
