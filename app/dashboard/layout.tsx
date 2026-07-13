import type { ReactNode } from 'react';
import { QueryProvider } from '@/shared/components/providers/query-provider';

export default function DashboardLayout({ children }: { children: ReactNode }) {
  return <QueryProvider>{children}</QueryProvider>;
}
