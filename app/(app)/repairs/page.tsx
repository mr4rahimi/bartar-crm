import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { RepairsView } from '@/features/repairs/components/repairs-view';

export default async function RepairsPage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');

  return <RepairsView permissions={user.permissions} />;
}
