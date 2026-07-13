'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useState, type ReactNode } from 'react';
import { MoreHorizontal } from 'lucide-react';
import { cn } from '@/shared/lib/cn';
import type { NavItem } from '@/shared/constants/navigation';
import { ThemeToggle } from '@/shared/components/theme-toggle';

const MAX_VISIBLE_ITEMS = 3;

type BottomNavProps = {
  items: NavItem[];
  userName: string;
  logoutSlot: ReactNode;
};

export function BottomNav({ items, userName, logoutSlot }: BottomNavProps) {
  const pathname = usePathname();
  const [isMoreOpen, setIsMoreOpen] = useState(false);

  const visibleItems = items.slice(0, MAX_VISIBLE_ITEMS);
  const moreItems = items.slice(MAX_VISIBLE_ITEMS);

  return (
    <>
      {isMoreOpen && (
        <div
          className="fixed inset-0 z-40 bg-black/40 md:hidden"
          onClick={() => setIsMoreOpen(false)}
        >
          <div
            className="absolute inset-x-0 bottom-16 space-y-1 rounded-t-2xl border-t border-border bg-card p-4"
            onClick={(event) => event.stopPropagation()}
          >
            <div className="pb-2 text-sm font-bold">{userName}</div>
            {moreItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                onClick={() => setIsMoreOpen(false)}
                className="flex items-center gap-3 rounded-md px-3 py-2.5 text-sm font-semibold hover:bg-muted"
              >
                <item.icon className="h-4 w-4" />
                {item.label}
              </Link>
            ))}
            <div className="space-y-2 pt-2">
              <ThemeToggle />
              {logoutSlot}
            </div>
          </div>
        </div>
      )}

      <nav className="fixed inset-x-0 bottom-0 z-50 flex h-16 items-stretch border-t border-border bg-card md:hidden">
        {visibleItems.map((item) => {
          const isActive = pathname.startsWith(item.href);
          return (
            <Link
              key={item.href}
              href={item.href}
              className={cn(
                'flex flex-1 flex-col items-center justify-center gap-1 text-[11px] font-bold',
                isActive ? 'text-primary' : 'text-muted-foreground',
              )}
            >
              <item.icon className="h-5 w-5" />
              {item.label}
            </Link>
          );
        })}
        <button
          type="button"
          onClick={() => setIsMoreOpen((open) => !open)}
          className={cn(
            'flex flex-1 flex-col items-center justify-center gap-1 text-[11px] font-bold',
            isMoreOpen ? 'text-primary' : 'text-muted-foreground',
          )}
        >
          <MoreHorizontal className="h-5 w-5" />
          بیشتر
        </button>
      </nav>
    </>
  );
}
