import { INVOICE_HEADER } from '@/features/invoices/constants/invoice.constants';
import type { TicketDto } from '../types/ticket.types';

const fa = (value: number) => value.toLocaleString('fa-IR');

const formatDateTime = (value: Date | string | null) =>
  value
    ? new Date(value).toLocaleString('fa-IR', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
      })
    : '—';

type DeliveryReceiptProps = {
  ticket: TicketDto;
  delivererName: string;
  invoice: { invoiceNumber: string; total: number; warrantyMonths: number | null } | null;
};

export function DeliveryReceiptView({ ticket, delivererName, invoice }: DeliveryReceiptProps) {
  const isRepaired = ticket.status !== 'UNREPAIRABLE';

  const deviceTitle = [ticket.device.deviceType, ticket.device.brand, ticket.device.model]
    .filter(Boolean)
    .join(' ');

  return (
    <>
      <style>{`
        @page { size: A5 portrait; margin: 0; }
        @media print { .no-print { display: none !important; } }
        html, body { background: #fff; }
      `}</style>

      <div
        dir="rtl"
        className="mx-auto flex flex-col bg-white text-black"
        style={{ width: '148mm', height: '210mm', padding: '7mm' }}
      >
        {/* ---------- سربرگ ---------- */}
        <header className="flex items-center justify-between border-b-2 border-black pb-2">
          <div className="w-[34mm] space-y-1">
            <div className="flex items-baseline gap-1">
              <span className="text-[7pt] text-gray-600">شماره پذیرش:</span>
              <span className="text-[11pt] font-black">{ticket.ticketNumber}</span>
            </div>
            <div className="flex items-baseline gap-1">
              <span className="text-[7pt] text-gray-600">تاریخ تحویل:</span>
              <span className="text-[8pt] font-bold">
                {formatDateTime(ticket.deliveredToCustomerAt ?? new Date())}
              </span>
            </div>
          </div>

          <div className="flex-1 text-center">
            <div className="text-[15pt] font-black leading-tight">{INVOICE_HEADER.title}</div>
            <div className="text-[8pt] font-bold text-gray-700">{INVOICE_HEADER.subtitle}</div>
            <div className="mt-1 text-[9pt] font-black">رسید تحویل دستگاه</div>
          </div>

          <div className="flex w-[34mm] justify-start">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={INVOICE_HEADER.logoPath}
              alt=""
              style={{ maxHeight: '17mm', maxWidth: '30mm', objectFit: 'contain' }}
            />
          </div>
        </header>

        {/* ---------- مشتری ---------- */}
        <section className="mt-2.5 rounded border border-gray-300 px-2.5 py-2">
          <div className="mb-1 text-[7.5pt] font-black text-gray-600">مشخصات مشتری</div>
          <div className="grid grid-cols-2 gap-2">
            <div>
              <div className="text-[6.5pt] text-gray-500">نام و نام خانوادگی</div>
              <div className="text-[9pt] font-bold">{ticket.customer.name}</div>
            </div>
            <div>
              <div className="text-[6.5pt] text-gray-500">شماره تماس</div>
              <div dir="ltr" className="text-right text-[9pt] font-bold">
                {ticket.customer.phone}
              </div>
            </div>
          </div>
        </section>

        {/* ---------- دستگاه ---------- */}
        <section className="mt-2 rounded border border-gray-300 px-2.5 py-2">
          <div className="mb-1 text-[7.5pt] font-black text-gray-600">مشخصات دستگاه</div>
          <div className="grid grid-cols-2 gap-2">
            <div>
              <div className="text-[6.5pt] text-gray-500">دستگاه</div>
              <div className="text-[8.5pt] font-bold">{deviceTitle}</div>
            </div>
            <div>
              <div className="text-[6.5pt] text-gray-500">سریال</div>
              <div dir="ltr" className="text-right text-[8.5pt] font-bold">
                {ticket.device.serial || '—'}
              </div>
            </div>
          </div>

          {ticket.accessories.length > 0 && (
            <div className="mt-1.5 border-t border-gray-200 pt-1.5">
              <div className="text-[6.5pt] text-gray-500">متعلقات تحویلی</div>
              <div className="text-[8pt] font-semibold leading-5">
                {ticket.accessories.join('، ')}
              </div>
            </div>
          )}
        </section>

        {/* ---------- نتیجه ---------- */}
        <section className="mt-2 rounded border-2 border-black px-2.5 py-2">
          <div className="flex items-center justify-between">
            <span className="text-[8pt] font-black">نتیجه بررسی:</span>
            <span className="text-[10pt] font-black">
              {isRepaired ? 'دستگاه تعمیر شد' : 'دستگاه تعمیر نشد'}
            </span>
          </div>

          {!isRepaired && ticket.unrepairableReason && (
            <div className="mt-1.5 border-t border-gray-300 pt-1.5">
              <div className="text-[6.5pt] text-gray-500">دلیل عدم تعمیر</div>
              <div className="text-[8pt] leading-5">{ticket.unrepairableReason}</div>
            </div>
          )}

          {invoice && (
            <div className="mt-1.5 flex items-center justify-between border-t border-gray-300 pt-1.5 text-[8pt]">
              <span className="text-gray-600">
                فاکتور شماره {invoice.invoiceNumber}
                {invoice.warrantyMonths ? ` — ${fa(invoice.warrantyMonths)} ماه ضمانت` : ''}
              </span>
              <span className="font-black">{fa(invoice.total)} تومان</span>
            </div>
          )}
        </section>

        {/* ---------- تعهد ---------- */}
        <section className="mt-2.5 flex-1">
          <p className="text-[8.5pt] font-bold leading-6">
            اینجانب <span className="border-b border-dotted border-black px-6">{ticket.customer.name}</span>{' '}
            {isRepaired
              ? 'دستگاه فوق را به همراه کلیه متعلقات ذکرشده، سالم و کامل تحویل گرفتم و هیچ‌گونه ادعایی نسبت به دستگاه، متعلقات و روند انجام کار ندارم.'
              : 'دستگاه فوق را که طبق توضیحات فوق تعمیر نشده است، به همراه کلیه متعلقات ذکرشده و در همان وضعیتی که تحویل مجموعه داده بودم، دریافت کردم و هیچ‌گونه ادعایی نسبت به دستگاه، متعلقات و روند بررسی انجام‌شده ندارم.'}
          </p>

          <ul className="mt-2 list-disc space-y-[2pt] pr-4 text-[6.5pt] leading-[10pt] text-gray-700">
            <li>
              {isRepaired
                ? 'پس از تحویل دستگاه، مجموعه هیچ مسئولیتی در قبال آسیب‌های فیزیکی وارده نخواهد داشت.'
                : 'دستگاه بدون انجام تعمیر و در وضعیت اولیه تحویل داده شد؛ پس از تحویل، مجموعه هیچ مسئولیتی در قبال آن نخواهد داشت.'}
            </li>            <li>
              موارد شامل ضمانت صرفاً بر اساس فاکتور صادرشده و شرایط مندرج در آن قابل پیگیری است.
            </li>
            <li>این رسید تنها به‌منظور بایگانی مجموعه صادر شده است.</li>
          </ul>
        </section>

        {/* ---------- امضاها ---------- */}
        <section className="mt-2">
          <div className="grid grid-cols-2 gap-4 text-[8pt]">
            <div className="rounded border border-gray-300 px-2 py-2">
              <div className="font-bold">تحویل‌گیرنده (مشتری)</div>
              <div className="mt-0.5 text-[6.5pt] text-gray-500">نام و امضا</div>
              <div className="h-[14mm]" />
            </div>
            <div className="rounded border border-gray-300 px-2 py-2">
              <div className="font-bold">تحویل‌دهنده</div>
              <div className="mt-0.5 text-[7.5pt]">{delivererName}</div>
              <div className="h-[14mm]" />
            </div>
          </div>
        </section>

        {/* ---------- پاورقی ---------- */}
        <footer className="mt-2 border-t-2 border-black pt-1.5 text-center text-[6.5pt] leading-[9pt]">
          <div>نشانی: {INVOICE_HEADER.address}</div>
          <div className="font-bold">تلفن: {INVOICE_HEADER.phone}</div>
        </footer>
      </div>
    </>
  );
}
