import { Suspense } from 'react';
import { LoginForm } from '@/features/authentication/components/login-form';

// موبایل: تمام‌صفحه روی surface | دسکتاپ: کارت دوپنله (پنل برند + فرم) — مطابق ماکاپ ui/
export default function LoginPage() {
  return (
    <main className="min-h-screen bg-background md:flex md:items-center md:justify-center md:p-6">
      <div className="flex min-h-screen flex-col bg-card px-6 py-8 md:min-h-[560px] md:w-full md:max-w-4xl md:flex-row md:overflow-hidden md:rounded-2xl md:border md:border-border md:p-0 md:shadow-2xl">
        <div className="hidden md:flex md:flex-1 md:flex-col md:items-center md:justify-center md:gap-4 md:bg-accent md:p-10">
          <div className="flex h-[72px] w-[72px] items-center justify-center rounded-[20px] bg-primary text-3xl font-extrabold text-primary-foreground">
            ب
          </div>
          <div className="text-[22px] font-extrabold">برتر CRM</div>
          <p className="text-center text-[13px] text-muted-foreground">
            مدیریت درخواست قطعه، خرید و تعمیرات در یک سامانه
          </p>
        </div>

        <div className="flex flex-1 flex-col justify-center gap-5 md:max-w-md md:p-12">
          <div className="mb-4 flex flex-col items-center gap-2 md:hidden">
            <div className="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary text-2xl font-extrabold text-primary-foreground">
              ب
            </div>
            <div className="text-[19px] font-extrabold">ورود به برتر CRM</div>
            <p className="text-[13px] text-muted-foreground">
              سامانه مدیریت تعمیرات و خرید قطعات
            </p>
          </div>

          <div className="hidden text-xl font-extrabold md:block">ورود به حساب کاربری</div>

          <Suspense>
            <LoginForm />
          </Suspense>
        </div>
      </div>
    </main>
  );
}
