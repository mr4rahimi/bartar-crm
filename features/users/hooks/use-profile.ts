'use client';

import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { apiFetch } from '@/shared/lib/api-client';
import type { ProfileDto } from '../types/profile.types';

export function useProfile() {
  return useQuery({
    queryKey: ['profile'],
    queryFn: () => apiFetch<ProfileDto>('/api/v1/profile'),
  });
}

function useInvalidateProfile() {
  const queryClient = useQueryClient();
  return () => queryClient.invalidateQueries({ queryKey: ['profile'] });
}

export function useUpdateProfile() {
  const invalidate = useInvalidateProfile();
  return useMutation({
    mutationFn: (input: { name: string }) =>
      apiFetch<ProfileDto>('/api/v1/profile', {
        method: 'PATCH',
        body: JSON.stringify(input),
      }),
    onSuccess: invalidate,
  });
}

export function useUploadAvatar() {
  const invalidate = useInvalidateProfile();
  return useMutation({
    mutationFn: async (file: File) => {
      const formData = new FormData();
      formData.append('file', file);

      const response = await fetch('/api/v1/profile/avatar', {
        method: 'POST',
        body: formData,
      });
      const payload = await response.json().catch(() => null);

      if (!response.ok || payload?.success === false) {
        throw new Error(payload?.error ?? 'خطا در بارگذاری تصویر');
      }
      return payload.data as ProfileDto;
    },
    onSuccess: invalidate,
  });
}

export function useRemoveAvatar() {
  const invalidate = useInvalidateProfile();
  return useMutation({
    mutationFn: () => apiFetch<ProfileDto>('/api/v1/profile/avatar', { method: 'DELETE' }),
    onSuccess: invalidate,
  });
}

export function useChangePassword() {
  return useMutation({
    mutationFn: (input: {
      currentPassword: string;
      newPassword: string;
      confirmPassword: string;
    }) =>
      apiFetch<null>('/api/v1/profile/password', {
        method: 'POST',
        body: JSON.stringify(input),
      }),
  });
}
