import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { ProfileView } from '@/features/users/components/profile-view';

export default async function ProfilePage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');

  return <ProfileView />;
}
