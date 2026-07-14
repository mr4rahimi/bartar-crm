import type { ReactNode } from 'react';
import { QueryProvider } from '@/shared/components/providers/query-provider';
import { ThemeToggle } from '@/shared/components/theme-toggle';

// صفحه عمومی — بدون احراز هویت
export default function PublicPricesLayout({ children }: { children: ReactNode }) {
  return (
    <QueryProvider>
      <div className="min-h-screen bg-background">
        <header className="sticky top-0 z-30 border-b border-border bg-card">
          <div className="mx-auto flex h-14 max-w-3xl items-center justify-between gap-3 px-4">
            <div className="flex items-center gap-2.5">
              <div className="flex h-8 w-8 items-center justify-center rounded-lg bg-primary text-sm font-extrabold text-primary-foreground">
                ب
              </div>
              <div>
                <div className="text-sm font-extrabold">اعلام هزینه قطعات</div>
                <div className="text-[10.5px] text-muted-foreground">برتر CRM</div>
              </div>
            </div>
            <ThemeToggle className="w-40" />
          </div>
        </header>
        <main className="mx-auto max-w-3xl p-4">{children}</main>
      </div>
    </QueryProvider>
  );
}
