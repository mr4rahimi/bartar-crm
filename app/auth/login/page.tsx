import { Suspense } from 'react';
import { LoginForm } from '@/features/authentication/components/login-form';

export default function LoginPage() {
  return (
    <main dir="rtl" className="flex min-h-screen items-center justify-center p-6">
      <div className="w-full max-w-sm space-y-6">
        <div className="space-y-1 text-center">
          <h1 className="text-2xl font-bold">Bartar CRM</h1>
          <p className="text-sm text-muted-foreground">برای ادامه وارد حساب خود شوید</p>
        </div>
        <Suspense>
          <LoginForm />
        </Suspense>
      </div>
    </main>
  );
}
