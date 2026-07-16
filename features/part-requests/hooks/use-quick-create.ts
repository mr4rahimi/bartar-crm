'use client';

import { useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';

// ساخت سریع برند از فرم درخواست — نیازمند EDIT_PRICE (سمت سرور بررسی می‌شود)
export function useQuickCreate() {
  const queryClient = useQueryClient();

  const createBrand = async (name: string) => {
    const brand = await apiFetch<{ id: string; name: string }>('/api/v1/brands-admin', {
      method: 'POST',
      body: JSON.stringify({ name }),
    });
    await queryClient.invalidateQueries({ queryKey: ['taxonomy'] });
    return brand;
  };

  return { createBrand };
}
