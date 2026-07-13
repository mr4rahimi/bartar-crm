'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import type { ReactNode } from 'react';
import { cn } from '@/shared/lib/cn';
import type { NavItem } from '@/shared/constants/navigation';
import { ThemeToggle } from '@/shared/components/theme-toggle';

type SidebarProps = {
  items: NavItem[];
  userName: string;
  logoutSlot: ReactNode;
};

export function Sidebar({ items, userName, logoutSlot }: SidebarProps) {
  const pathname = usePathname();

  return (
    <aside className="fixed inset-y-0 right-0 z-40 hidden w-64 flex-col border-l border-border bg-card md:flex">
      <div className="flex items-center gap-3 border-b border-border p-4">
        <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary text-base font-extrabold text-primary-foreground">
          ب
        </div>
        <div>
          <div className="text-sm font-extrabold">برتر CRM</div>
          <div className="text-xs text-muted-foreground">مدیریت تعمیرات و خرید</div>
        </div>
      </div>

      <nav className="flex-1 space-y-1 p-3">
        {items.map((item) => {
          const isActive = pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex items-center gap-3 rounded-md px-3 py-2.5 text-sm font-semibold transition-colors',
                isActive
                  ? 'bg-accent text-accent-foreground'
                  : 'text-foreground hover:bg-muted',
              )}
            >
              <item.icon className="h-4 w-4" />
              {item.label}
            </Link>
          );
        })}
      </nav>

      <div className="space-y-3 border-t border-border p-4">
        <ThemeToggle />
        <div className="text-sm font-semibold">{userName}</div>
        {logoutSlot}
      </div>
    </aside>
  );
}
