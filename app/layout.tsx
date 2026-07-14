import type { Metadata } from 'next';
import type { ReactNode } from 'react';
import 'vazirmatn/Vazirmatn-font-face.css';
import './globals.css';

export const metadata: Metadata = {
  title: 'برتر CRM',
  description: 'سیستم مدیریت تعمیرات، خرید قطعات و خدمات پس از فروش',
};

// تم پیش‌فرض تیره است (مطابق ماکاپ) — قبل از رندر اعمال می‌شود تا فلش نداشته باشیم
const themeInitScript = `try{var t=localStorage.getItem('theme')||'dark';if(t==='dark')document.documentElement.classList.add('dark')}catch(e){document.documentElement.classList.add('dark')}`;

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="fa" dir="rtl" suppressHydrationWarning>
      <body className="font-sans antialiased">
        <script dangerouslySetInnerHTML={{ __html: themeInitScript }} />
        {children}
      </body>
    </html>
  );
}
