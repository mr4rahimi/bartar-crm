'use client';

import type { ReactNode } from 'react';
import { NAV_ITEMS } from '@/shared/constants/navigation';
import { Sidebar } from './sidebar';
import { BottomNav } from './bottom-nav';

type AppShellProps = {
  userName: string;
  permissions: string[];
  logoutSlot: ReactNode;
  children: ReactNode;
};

// آیتم‌های منو بر اساس Permission نمایش داده می‌شوند؛ Backend همیشه دوباره بررسی می‌کند
export function AppShell({ userName, permissions, logoutSlot, children }: AppShellProps) {
  const items = NAV_ITEMS.filter(
    (item) => !item.permission || permissions.includes(item.permission),
  );

  return (
    <div className="min-h-screen bg-background">
      <Sidebar items={items} userName={userName} logoutSlot={logoutSlot} />

      <header className="sticky top-0 z-30 flex h-14 items-center gap-3 border-b border-border bg-card px-4 md:hidden">
        <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-sm font-extrabold text-primary-foreground">
          ب
        </div>
        <div className="text-sm font-extrabold">برتر CRM</div>
      </header>

      <div className="md:pr-64">
        <main className="p-4 pb-24 md:p-6">{children}</main>
      </div>

      <BottomNav items={items} userName={userName} logoutSlot={logoutSlot} />
    </div>
  );
}
