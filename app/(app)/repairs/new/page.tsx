import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { ReceptionFormView } from '@/features/repairs/components/reception-form-view';

export default async function NewReceptionPage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('CREATE_REPAIR')) redirect('/repairs');

  return <ReceptionFormView />;
}
