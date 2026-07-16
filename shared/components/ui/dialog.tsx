'use client';

import type { ReactNode } from 'react';
import { X } from 'lucide-react';

type DialogProps = {
  open: boolean;
  onClose: () => void;
  title: string;
  children: ReactNode;
};

// موبایل: Bottom Sheet | دسکتاپ: مودال مرکزی — مطابق ماکاپ ui/
// z-[70]: بالاتر از Bottom Nav (z-50) تا دکمه‌ی ثبت هرگز زیر نوار پایین نیفتد
export function Dialog({ open, onClose, title, children }: DialogProps) {
  if (!open) return null;

  return (
    <div
      className="fixed inset-0 z-[70] flex items-end justify-center bg-black/40 md:items-center md:p-6"
      onClick={onClose}
    >
      <div
        className="max-h-[85vh] w-full overflow-y-auto rounded-t-2xl border border-border bg-card p-5 pb-[max(1.5rem,env(safe-area-inset-bottom))] md:max-h-[90vh] md:max-w-lg md:rounded-2xl md:pb-5"
        onClick={(event) => event.stopPropagation()}
      >
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-base font-extrabold">{title}</h2>
          <button
            type="button"
            onClick={onClose}
            className="rounded-md p-1 text-muted-foreground hover:bg-muted"
            aria-label="بستن"
          >
            <X className="h-5 w-5" />
          </button>
        </div>
        {children}
      </div>
    </div>
  );
}
