import type { ReactNode } from 'react';

// چیدمان چاپ — بدون سایدبار و ناوبری
export default function PrintLayout({ children }: { children: ReactNode }) {
  return <div className="bg-white text-black">{children}</div>;
}
