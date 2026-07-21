import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { MyRepairsView } from '@/features/repairs/components/my-repairs-view';

export default async function MyRepairsPage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('REPAIR_DEVICE')) redirect('/dashboard');

  return <MyRepairsView currentUserId={user.id} permissions={user.permissions} />;
}
