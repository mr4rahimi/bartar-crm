'use client';

import type { LucideIcon } from 'lucide-react';
import { cn } from '@/shared/lib/cn';

type IconButtonProps = {
  icon: LucideIcon;
  label: string;
  onClick?: () => void;
  disabled?: boolean;
  tone?: 'default' | 'destructive' | 'primary';
};

const TONES = {
  default: 'text-muted-foreground hover:bg-muted hover:text-foreground',
  primary: 'text-primary hover:bg-accent',
  destructive: 'text-destructive hover:bg-destructive/10',
};

/** دکمه آیکونی با راهنمای شناور (Tooltip) */
export function IconButton({
  icon: Icon,
  label,
  onClick,
  disabled = false,
  tone = 'default',
}: IconButtonProps) {
  return (
    <span className="group relative inline-flex">
      <button
        type="button"
        onClick={onClick}
        disabled={disabled}
        aria-label={label}
        className={cn(
          'flex h-8 w-8 items-center justify-center rounded-md transition-colors disabled:cursor-not-allowed disabled:opacity-40',
          TONES[tone],
        )}
      >
        <Icon className="h-4 w-4" />
      </button>
      <span className="pointer-events-none absolute bottom-full left-1/2 z-50 mb-1 -translate-x-1/2 whitespace-nowrap rounded-md bg-foreground px-2 py-1 text-[10.5px] font-bold text-background opacity-0 transition-opacity group-hover:opacity-100">
        {label}
      </span>
    </span>
  );
}
