import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { AdminPricesView } from '@/features/pricing/components/admin-prices-view';

export default async function PricingPage() {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');

  return <AdminPricesView canEdit={user.permissions.includes('EDIT_PRICE')} />;
}
