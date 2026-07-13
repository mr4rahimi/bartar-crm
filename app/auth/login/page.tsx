import { Suspense } from 'react';
import { LoginForm } from '@/features/authentication/components/login-form';

export default function LoginPage() {
  return (
    <main className="flex min-h-screen items-center justify-center bg-background p-6">
      <div className="w-full max-w-sm space-y-6 rounded-2xl border border-border bg-card p-6 shadow-sm">
        <div className="space-y-3 text-center">
          <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-xl bg-primary text-xl font-extrabold text-primary-foreground">
            ب
          </div>
          <h1 className="text-xl font-extrabold">برتر CRM</h1>
          <p className="text-sm text-muted-foreground">برای ادامه وارد حساب خود شوید</p>
        </div>
        <Suspense>
          <LoginForm />
        </Suspense>
      </div>
    </main>
  );
}
