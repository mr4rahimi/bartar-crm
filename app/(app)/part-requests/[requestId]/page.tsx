import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { PartRequestDetailView } from '@/features/part-requests/components/part-request-detail-view';

type PageProps = { params: { requestId: string } };

export default async function PartRequestDetailPage({ params }: PageProps) {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');

  return <PartRequestDetailView requestId={params.requestId} permissions={user.permissions} />;
}
