'use client';

import { useMutation } from '@tanstack/react-query';
import type { LoginInput } from '../validators/login.schema';
import type { AuthenticatedUser } from '../types/session.types';

type LoginResponse =
  | { success: true; data: { user: AuthenticatedUser } }
  | { success: false; message: string; errors: { field?: string; message: string }[] };

async function loginRequest(input: LoginInput): Promise<AuthenticatedUser> {
  const res = await fetch('/api/v1/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(input),
  });

  const json = (await res.json()) as LoginResponse;

  if (!json.success) {
    throw new Error(json.message);
  }

  return json.data.user;
}

export function useLogin() {
  return useMutation({ mutationFn: loginRequest });
}
