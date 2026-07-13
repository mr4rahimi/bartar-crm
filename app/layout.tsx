import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Bartar CRM',
  description: 'سیستم مدیریت تعمیرات، خرید قطعات و خدمات پس از فروش',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fa" dir="rtl">
      <body className="min-h-screen bg-background text-foreground antialiased">
        {children}
      </body>
    </html>
  );
}
