'use client';

import { useEffect } from 'react';

/** پس از رندر کامل، پنجره‌ی چاپ باز می‌شود */
export function PrintTrigger() {
  useEffect(() => {
    const timer = setTimeout(() => window.print(), 700);
    return () => clearTimeout(timer);
  }, []);

  return null;
}
