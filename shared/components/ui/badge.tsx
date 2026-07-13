import type { ReactNode } from 'react';
import { cn } from '@/shared/lib/cn';

type BadgeVariant = 'blue' | 'green' | 'red' | 'muted';

// رنگ‌ها از FAMILY_COLORS ماکاپ ui/ (حالت روشن و تیره)
const VARIANT_CLASSES: Record<BadgeVariant, string> = {
  blue: 'bg-[#eaf1fe] text-[#1d4ed8] dark:bg-[#122236] dark:text-[#60a5fa]',
  green: 'bg-[#eafaf0] text-[#15803d] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
  red: 'bg-[#fdecec] text-[#b91c1c] dark:bg-[#341313] dark:text-[#f87171]',
  muted: 'bg-muted text-muted-foreground',
};

export function Badge({
  variant = 'muted',
  children,
  className,
}: {
  variant?: BadgeVariant;
  children: ReactNode;
  className?: string;
}) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-[7px] px-2 py-0.5 text-[11px] font-bold',
        VARIANT_CLASSES[variant],
        className,
      )}
    >
      {children}
    </span>
  );
}
