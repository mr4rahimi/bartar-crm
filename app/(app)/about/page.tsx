import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { AboutView } from '@/features/settings/components/about-view';

export default async function AboutPage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('VIEW_SETTINGS')) redirect('/dashboard');

  return <AboutView />;
}
