import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { CatalogView } from '@/features/pricing/components/catalog-view';

export default async function CatalogPage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('EDIT_PRICE')) redirect('/dashboard');

  return <CatalogView />;
}
