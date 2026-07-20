import { redirect } from 'next/navigation';
import { getCurrentUser } from '@/features/authentication/utils/current-user.utils';
import { getInvoiceService } from '@/features/invoices/services/invoice.service';
import { InvoicePrintView } from '@/features/invoices/components/invoice-print-view';
import { PrintTrigger } from '@/features/repairs/components/print-trigger';

type PageProps = { params: { invoiceId: string } };

export default async function InvoicePrintPage({ params }: PageProps) {
  const user = await getCurrentUser();
  if (!user) redirect('/auth/login');
  if (!user.permissions.includes('VIEW_INVOICE')) redirect('/repairs');

  const invoice = await getInvoiceService(params.invoiceId);

  return (
    <>
      <PrintTrigger />
      <InvoicePrintView invoice={invoice} />
    </>
  );
}
