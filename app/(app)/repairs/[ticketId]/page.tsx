import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { TicketDetailView } from '@/features/repairs/components/ticket-detail-view';

type PageProps = { params: { ticketId: string } };

export default async function TicketDetailPage({ params }: PageProps) {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('VIEW_REPAIR')) redirect('/dashboard');

  return (
    <TicketDetailView
      ticketId={params.ticketId}
      currentUserId={user.id}
      permissions={user.permissions}
    />
  );
}
