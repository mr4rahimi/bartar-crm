import { redirect } from 'next/navigation';
import type { ReactNode } from 'react';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { LogoutButton } from '@/features/authentication/components/logout-button';
import { QueryProvider } from '@/shared/components/providers/query-provider';
import { ToastProvider } from '@/shared/components/providers/toast-provider';
import { AppShell } from '@/shared/components/layout/app-shell';

export default async function AppLayout({ children }: { children: ReactNode }) {
  const user = await getCurrentUser();

  if (!user) {
    redirect('/auth/login');
  }

  return (
    <QueryProvider>
      <ToastProvider>
        <AppShell
          userName={user.name}
          permissions={user.permissions}
          logoutSlot={<LogoutButton />}
        >
          {children}
        </AppShell>
      </ToastProvider>
    </QueryProvider>
  );
}
