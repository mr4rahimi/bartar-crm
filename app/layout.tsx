import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import { Vazirmatn } from 'next/font/google';
import './globals.css';

const vazirmatn = Vazirmatn({
  subsets: ['arabic'],
  variable: '--font-vazirmatn',
});

export const metadata: Metadata = {
  title: 'برتر CRM',
  description: 'سیستم مدیریت تعمیرات، خرید قطعات و خدمات پس از فروش',
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="fa" dir="rtl" suppressHydrationWarning>
      <body className={`${vazirmatn.variable} font-sans antialiased`}>{children}</body>
    </html>
  );
}
