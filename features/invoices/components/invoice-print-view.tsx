import {
  INVOICE_HEADER,
  INVOICE_NOTE_WARRANTY,
  INVOICE_NOTES_FIXED,
  INVOICE_NOTE_BATTERY,
} from '../constants/invoice.constants';
import { numberToPersianWords } from '@/shared/lib/number-to-words';
import type { InvoiceDto } from '../types/invoice.types';

const fa = (value: number) => value.toLocaleString('fa-IR');

export function InvoicePrintView({ invoice }: { invoice: InvoiceDto }) {
  const notes: string[] = [];
  if (invoice.warrantyMonths) {
    notes.push(INVOICE_NOTE_WARRANTY.replace('{months}', fa(invoice.warrantyMonths)));
  }
  notes.push(...INVOICE_NOTES_FIXED);
  if (invoice.hasBatteryNote) notes.push(INVOICE_NOTE_BATTERY);
  notes.push(...invoice.extraNotes);

  const totalRial = invoice.total * 10;
  

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
        style={{ width: '148mm', height: '210mm', padding: '6mm' }}
      >
        {/* ---------- سربرگ ---------- */}
        <header className="flex items-center justify-between border-b-2 border-black pb-2">
          <div className="w-[34mm] space-y-1">
            <div className="flex items-baseline gap-1">
              <span className="text-[7pt] text-gray-600">شماره فاکتور:</span>
              <span className="text-[10pt] font-black">{invoice.invoiceNumber}</span>
            </div>
            <div className="flex items-baseline gap-1">
              <span className="text-[7pt] text-gray-600">تاریخ:</span>
              <span className="text-[8pt] font-bold">
                {new Date(invoice.createdAt).toLocaleDateString('fa-IR')}
              </span>
            </div>
          </div>

          <div className="flex-1 text-center">
            <div className="text-[16pt] font-black leading-tight">{INVOICE_HEADER.title}</div>
            <div className="text-[8pt] font-bold text-gray-700">{INVOICE_HEADER.subtitle}</div>
          </div>

          <div className="flex w-[34mm] justify-start">
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src={INVOICE_HEADER.logoPath}
              alt=""
              style={{ maxHeight: '18mm', maxWidth: '30mm', objectFit: 'contain' }}
            />
          </div>
        </header>

        {/* ---------- مشخصات خریدار ---------- */}
        <section className="mt-2 grid grid-cols-3 gap-2 rounded border border-gray-300 px-2 py-1.5">
          {[
            { label: 'نام خریدار', value: invoice.customerName },
            { label: 'شماره تماس', value: invoice.customerPhone },
            { label: 'شماره پذیرش', value: invoice.ticketNumber },
          ].map((field) => (
            <div key={field.label}>
              <div className="text-[6.5pt] text-gray-500">{field.label}</div>
              <div className="text-[8.5pt] font-bold">{field.value}</div>
            </div>
          ))}
        </section>

        {/* ---------- اقلام ---------- */}
        <table className="mt-2 w-full border-collapse text-right">
          <thead>
            <tr className="bg-gray-100">
              {['#', 'شرح', 'تعداد', 'قیمت واحد', 'قیمت کل'].map((head, index) => (
                <th
                  key={head}
                  className="border border-gray-400 px-1.5 py-1 text-[7.5pt] font-black"
                  style={{
                    width: index === 0 ? '8mm' : index === 1 ? 'auto' : '22mm',
                    textAlign: index === 1 ? 'right' : 'center',
                  }}
                >
                  {head}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {invoice.items.map((item, index) => (
              <tr key={item.id}>
                <td className="border border-gray-400 px-1.5 py-1 text-center text-[7.5pt]">
                  {fa(index + 1)}
                </td>
                <td className="border border-gray-400 px-1.5 py-1 text-[8pt] font-semibold">
                  {item.title}
                </td>
                <td className="border border-gray-400 px-1.5 py-1 text-center text-[8pt]">
                  {fa(item.quantity)}
                </td>
                <td className="border border-gray-400 px-1.5 py-1 text-center text-[8pt]">
                  {fa(item.unitPrice)}
                </td>
                <td className="border border-gray-400 px-1.5 py-1 text-center text-[8pt] font-bold">
                  {fa(item.total)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* ---------- جمع‌ها ---------- */}
         <section className="mt-2 flex justify-end">
          <div className="w-[62mm] space-y-1">
            <div className="flex justify-between text-[8pt]">
              <span className="text-gray-600">جمع کل</span>
              <span className="font-bold">{fa(invoice.subtotal)} تومان</span>
            </div>
            {invoice.discountAmount > 0 && (
              <div className="flex justify-between text-[8pt]">
                <span className="text-gray-600">
                  تخفیف
                  {invoice.discountType === 'PERCENT' && ` (${fa(invoice.discountValue ?? 0)}٪)`}
                </span>
                <span className="font-bold">{fa(invoice.discountAmount)} تومان</span>
              </div>
            )}
            <div className="flex justify-between border-t border-black pt-1 text-[9.5pt]">
              <span className="font-black">قابل پرداخت</span>
              <span className="font-black">{fa(invoice.total)} تومان</span>
            </div>
            <div className="text-left text-[7pt] text-gray-600">
              معادل {fa(totalRial)} ریال
            </div>
          </div>
        </section>

        <div className="mt-1 rounded bg-gray-100 px-2 py-1 text-[7.5pt] font-bold">
          به حروف: {numberToPersianWords(totalRial)} ریال
        </div>

        {/* ---------- توضیحات ---------- */}
        <section className="mt-2 flex-1">
          <div className="mb-1 text-[8pt] font-black">توضیحات</div>
          <ol className="list-decimal space-y-[1.5pt] pr-3.5 text-[6.5pt] leading-[9pt]">
            {notes.map((note, index) => (
              <li key={index}>{note}</li>
            ))}
          </ol>
        </section>

        {/* ---------- پاورقی ---------- */}
        <footer>
          <div className="mb-2 flex justify-between px-6 text-[8pt] font-bold">
            <span>امضای خریدار</span>
            <span>امضای فروشنده</span>
          </div>
          <div className="border-t-2 border-black pt-1.5 text-center text-[6.5pt] leading-[9pt]">
            <div>نشانی: {INVOICE_HEADER.address}</div>
            <div className="font-bold">تلفن: {INVOICE_HEADER.phone}</div>
          </div>
        </footer>
      </div>
    </>
  );
}
