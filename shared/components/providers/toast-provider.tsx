'use client';

import { createContext, useCallback, useContext, useState, type ReactNode } from 'react';
import { cn } from '@/shared/lib/cn';

type ToastType = 'success' | 'error';
type ToastItem = { id: number; message: string; type: ToastType };

const ToastContext = createContext<{ toast: (message: string, type?: ToastType) => void } | null>(
  null,
);

export function useToast() {
  const context = useContext(ToastContext);
  if (!context) throw new Error('useToast باید داخل ToastProvider استفاده شود');
  return context;
}

export function ToastProvider({ children }: { children: ReactNode }) {
  const [toasts, setToasts] = useState<ToastItem[]>([]);

  const toast = useCallback((message: string, type: ToastType = 'success') => {
    const id = Date.now();
    setToasts((current) => [...current, { id, message, type }]);
    setTimeout(() => {
      setToasts((current) => current.filter((item) => item.id !== id));
    }, 3500);
  }, []);

  return (
    <ToastContext.Provider value={{ toast }}>
      {children}
      <div className="pointer-events-none fixed inset-x-0 bottom-20 z-[80] flex flex-col items-center gap-2 px-4 md:bottom-6">
        {toasts.map((item) => (
          <div
            key={item.id}
            className={cn(
              'w-full max-w-sm rounded-md border px-4 py-3 text-center text-[13px] font-bold shadow-lg',
              item.type === 'success' &&
                'border-[#c8f0d6] bg-[#eafaf0] text-[#15803d] dark:border-[#173d27] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
              item.type === 'error' &&
                'border-[#fac9c9] bg-[#fdecec] text-[#b91c1c] dark:border-[#4a1c1c] dark:bg-[#341313] dark:text-[#f87171]',
            )}
          >
            {item.message}
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
}
