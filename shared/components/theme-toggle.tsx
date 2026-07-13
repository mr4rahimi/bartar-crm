'use client';

import { useEffect, useState } from 'react';
import { Moon, Sun } from 'lucide-react';
import { cn } from '@/shared/lib/cn';

// تم پیش‌فرض «تیره» است (مطابق ماکاپ ui/) — انتخاب کاربر در localStorage ذخیره می‌شود
export function ThemeToggle({ className }: { className?: string }) {
  const [isDark, setIsDark] = useState(true);

  useEffect(() => {
    setIsDark(document.documentElement.classList.contains('dark'));
  }, []);

  const setTheme = (dark: boolean) => {
    setIsDark(dark);
    document.documentElement.classList.toggle('dark', dark);
    try {
      localStorage.setItem('theme', dark ? 'dark' : 'light');
    } catch {
      // localStorage ممکن است در دسترس نباشد
    }
  };

  const btnBase =
    'flex h-9 flex-1 items-center justify-center gap-1.5 rounded-md text-xs font-bold transition-colors';

  return (
    <div className={cn('flex gap-1 rounded-lg border border-border bg-background p-1', className)}>
      <button
        type="button"
        onClick={() => setTheme(false)}
        className={cn(btnBase, !isDark ? 'bg-accent text-accent-foreground' : 'text-muted-foreground')}
      >
        <Sun className="h-3.5 w-3.5" />
        روشن
      </button>
      <button
        type="button"
        onClick={() => setTheme(true)}
        className={cn(btnBase, isDark ? 'bg-accent text-accent-foreground' : 'text-muted-foreground')}
      >
        <Moon className="h-3.5 w-3.5" />
        تیره
      </button>
    </div>
  );
}
