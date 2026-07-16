'use client';

import { useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

// ساخت سریع برند/قطعه از فرم درخواست — مجوز سمت سرور بررسی می‌شود
export function useQuickCreate() {
  const queryClient = useQueryClient();

  const invalidate = () =>
    Promise.all([
      queryClient.invalidateQueries({ queryKey: ['taxonomy'] }),
      queryClient.invalidateQueries({ queryKey: ['parts'] }),
      queryClient.invalidateQueries({ queryKey: ['catalog'] }),
    ]);

  const createBrand = async (name: string) => {
    const brand = await apiFetch<{ id: string; name: string }>('/api/v1/brands-admin', {
      method: 'POST',
      body: JSON.stringify({ name }),
    });
    await invalidate();
    return brand;
  };

  const createPart = async (name: string) => {
    const part = await apiFetch<{ id: string; name: string }>('/api/v1/parts-quick', {
      method: 'POST',
      body: JSON.stringify({ name }),
    });
    await invalidate();
    return part;
  };

  return { createBrand, createPart };
}
