'use client';

import { useMutation } from '@tanstack/react-query';

async function logoutRequest(): Promise<void> {
  const res = await fetch('/api/v1/auth/logout', { method: 'POST' });

  if (!res.ok) {
    throw new Error('خروج ناموفق بود');
  }
}

export function useLogout() {
  return useMutation({ mutationFn: logoutRequest });
}
