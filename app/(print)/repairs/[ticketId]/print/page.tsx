import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { getTicketService } from '@/features/repairs/services/ticket.service';
import { ReceiptPrintView } from '@/features/repairs/components/receipt-print-view';
import { PrintTrigger } from '@/features/repairs/components/print-trigger';

type PageProps = { params: { ticketId: string } };

export default async function TicketPrintPage({ params }: PageProps) {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');

  const ticket = await getTicketService(params.ticketId);

  return (
    <>
      <PrintTrigger />
      <ReceiptPrintView ticket={ticket} />
    </>
  );
}
