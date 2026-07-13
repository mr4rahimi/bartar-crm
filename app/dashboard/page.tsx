import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { LogoutButton } from '@/features/authentication/components/logout-button';

export default async function DashboardPage() {
  const user = await getCurrentUser();

  if (!user) {
    redirect('/auth/login');
  }

  return (
    <main dir="rtl" className="mx-auto max-w-3xl space-y-6 p-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">داشبورد</h1>
          <p className="text-sm text-muted-foreground">خوش آمدی، {user.name}</p>
        </div>
        <LogoutButton />
      </div>
      <p className="text-sm text-muted-foreground">
        فیچر بعدی (Part Requests / Users) از اینجا ادامه می‌یابد.
      </p>
    </main>
  );
}
