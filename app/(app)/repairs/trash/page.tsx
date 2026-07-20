import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { TrashView } from '@/features/repairs/components/trash-view';

export default async function RepairsTrashPage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('DELETE_REPAIR')) redirect('/repairs');

  return <TrashView />;
}
