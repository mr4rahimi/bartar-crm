import Link from 'next/link';
import { ArrowLeft, Package, ShoppingCart, Tag } from 'lucide-react';
import { ThemeToggle } from '@/shared/components/theme-toggle';
import { QueryProvider } from '@/shared/components/providers/query-provider';

const FEATURES = [
  { icon: Package, title: 'ثبت درخواست قطعه', desc: 'ثبت سریع درخواست قطعه با شماره پذیرش و پیگیری وضعیت تا تحویل' },
  { icon: ShoppingCart, title: 'مدیریت خرید', desc: 'صف خرید، ثبت خرید از فروشندگان و به‌روزرسانی خودکار قیمت‌ها' },
  { icon: Tag, title: 'اعلام هزینه لحظه‌ای', desc: 'دسترسی سریع به قیمت روز قطعات برای اعلام به مشتری' },
];

export default function LandingPage() {
  return (
    <QueryProvider>
      <div className="min-h-screen bg-background text-foreground">
        {/* Header */}
        <header className="sticky top-0 z-30 border-b border-border bg-card/80 backdrop-blur">
          <div className="mx-auto flex h-16 max-w-5xl items-center justify-between px-4">
            <div className="flex items-center gap-2.5">
              <div className="flex h-9 w-9 items-center justify-center rounded-lg bg-primary text-lg font-extrabold text-primary-foreground">
                ب
              </div>
              <div>
                <div className="text-[15px] font-extrabold">برتر CRM</div>
                <div className="text-[10.5px] text-muted-foreground">مدیریت تعمیرات و خرید قطعات</div>
              </div>
            </div>
            <div className="hidden sm:block">
              <ThemeToggle className="w-44" />
            </div>
          </div>
        </header>

        {/* Hero */}
        <main className="mx-auto max-w-5xl px-4">
          <section className="flex flex-col items-center py-16 text-center sm:py-24">
            <span className="rounded-full border border-border bg-card px-3.5 py-1.5 text-[12px] font-bold text-muted-foreground">
              سامانه یکپارچه‌ی مدیریت قطعات
            </span>
            <h1 className="mt-6 text-3xl font-black leading-tight sm:text-5xl">
              مدیریت درخواست قطعه، خرید و
              <br />
              <span className="text-primary">اعلام هزینه</span> در یک سامانه
            </h1>
            <p className="mt-5 max-w-xl text-[14px] leading-7 text-muted-foreground sm:text-[15px]">
              از ثبت درخواست قطعه تا خرید و تحویل، همه‌ی مراحل را یک‌جا مدیریت کنید و
              قیمت روز قطعات را در لحظه به مشتری اعلام کنید.
            </p>

            <div className="mt-8 flex w-full flex-col gap-3 sm:w-auto sm:flex-row">
              <Link
                href="/prices"
                className="inline-flex h-12 items-center justify-center gap-2 rounded-md bg-primary px-7 text-[14px] font-bold text-primary-foreground transition-colors hover:bg-primary/90"
              >
                <Tag className="h-4 w-4" />
                مشاهده قیمت قطعات
              </Link>
              <Link
                href="/auth/login"
                className="inline-flex h-12 items-center justify-center gap-2 rounded-md border border-border bg-card px-7 text-[14px] font-bold transition-colors hover:bg-muted"
              >
                ورود به سامانه
                <ArrowLeft className="h-4 w-4" />
              </Link>
            </div>
          </section>

          {/* Features */}
          <section className="grid grid-cols-1 gap-4 pb-16 sm:grid-cols-3">
            {FEATURES.map((feature) => (
              <div key={feature.title} className="rounded-xl border border-border bg-card p-5">
                <div className="flex h-11 w-11 items-center justify-center rounded-lg bg-accent">
                  <feature.icon className="h-5 w-5 text-accent-foreground" />
                </div>
                <h3 className="mt-4 text-[15px] font-extrabold">{feature.title}</h3>
                <p className="mt-1.5 text-[13px] leading-6 text-muted-foreground">{feature.desc}</p>
              </div>
            ))}
          </section>
        </main>

        <footer className="border-t border-border">
          <div className="mx-auto max-w-5xl px-4 py-6 text-center text-[11.5px] text-muted-foreground">
            برتر CRM — تمامی حقوق محفوظ است
          </div>
        </footer>
      </div>
    </QueryProvider>
  );
}
