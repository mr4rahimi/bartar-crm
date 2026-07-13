'use client';

import { cn } from '@/shared/lib/cn';

type SwitchProps = {
  checked: boolean;
  onCheckedChange: (checked: boolean) => void;
  id?: string;
};

export function Switch({ checked, onCheckedChange, id }: SwitchProps) {
  return (
    <button
      type="button"
      id={id}
      role="switch"
      aria-checked={checked}
      onClick={() => onCheckedChange(!checked)}
      className={cn(
        'h-6 w-11 shrink-0 rounded-full p-0.5 transition-colors',
        checked ? 'bg-primary' : 'bg-muted',
      )}
    >
      <span
        className={cn(
          'block h-5 w-5 rounded-full bg-white shadow transition-transform',
          checked ? '-translate-x-5' : 'translate-x-0',
        )}
      />
    </button>
  );
}
