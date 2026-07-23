import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { getTicketService } from '@/features/repairs/services/ticket.service';
import { getTicketHistoryService } from '@/features/repairs/services/workflow.service';
import { getInvoiceByTicketService } from '@/features/invoices/services/invoice.service';
import { DeliveryReceiptView } from '@/features/repairs/components/delivery-receipt-view';
import { PrintTrigger } from '@/features/repairs/components/print-trigger';

type PageProps = { params: { ticketId: string } };

export default async function DeliveryReceiptPage({ params }: PageProps) {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('VIEW_REPAIR')) redirect('/dashboard');

  const ticket = await getTicketService(params.ticketId);

  // نام تحویل‌دهنده از تاریخچه؛ اگر هنوز ثبت نشده، کاربر جاری
  const history = await getTicketHistoryService(params.ticketId);
  const deliveryEntry = history.find((entry) => entry.action === 'DELIVER_TO_CUSTOMER');
  const delivererName = deliveryEntry?.changedByName ?? user.name;

  const invoice = await getInvoiceByTicketService(params.ticketId);

  return (
    <>
      <PrintTrigger />
      <DeliveryReceiptView
        ticket={ticket}
        delivererName={delivererName}
        invoice={
          invoice
            ? {
                invoiceNumber: invoice.invoiceNumber,
                total: invoice.total,
                warrantyMonths: invoice.warrantyMonths,
              }
            : null
        }
      />
    </>
  );
}
