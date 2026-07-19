import type { TicketDto } from '../types/ticket.types';
import { RECEIPT_HEADER, RECEIPT_TERMS } from '../constants/receipt.constants';

const formatDate = (value: Date | null) =>
  value ? new Date(value).toLocaleDateString('fa-IR') : '—';

const formatPrice = (value: number | null) =>
  value ? `${value.toLocaleString('fa-IR')} تومان` : '—';

const joinList = (items: string[]) => (items.length > 0 ? items.join('، ') : 'موردی ثبت نشده');

function Field({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <div className="text-[6.5pt] text-gray-500">{label}</div>
      <div className="text-[8pt] font-bold leading-4">{value}</div>
    </div>
  );
}

export function ReceiptPrintView({ ticket }: { ticket: TicketDto }) {
  const deviceTitle = [ticket.device.deviceType, ticket.device.brand, ticket.device.model]
    .filter(Boolean)
    .join(' ');

  return (
    <>
      <style>{`
        @page { size: A5 landscape; margin: 0; }
        @media print { .no-print { display: none !important; } }
        html, body { background: #fff; }
      `}</style>

      <div
        dir="rtl"
        className="mx-auto flex bg-white text-black"
        style={{ width: '210mm', height: '148mm', padding: '4mm', gap: '3mm' }}
      >
        {/* ---------- قبض مشتری (۳/۴) ---------- */}
        <section className="flex flex-1 flex-col" style={{ width: '150mm' }}>
          <header className="border-b border-black pb-1 text-center">
            <div className="text-[12pt] font-black">{RECEIPT_HEADER.title}</div>
            <div className="text-[8pt] font-bold">{RECEIPT_HEADER.subtitle}</div>
            <div className="text-[6.5pt]">
              {RECEIPT_HEADER.address} — {RECEIPT_HEADER.phone}
            </div>
          </header>

          <div className="grid grid-cols-4 gap-x-2 gap-y-1 border-b border-gray-300 py-1.5">
            <Field label="نام و نام خانوادگی" value={ticket.customer.name} />
            <Field label="دستگاه" value={deviceTitle} />
            <Field label="نوع پذیرش" value="جدید" />
            <Field label="شماره پذیرش" value={ticket.ticketNumber} />
            <Field label="هزینه تخمینی" value={formatPrice(ticket.estimatedCost)} />
            <Field label="سریال" value={ticket.device.serial ?? '—'} />
            <Field label="تاریخ ورود" value={formatDate(ticket.createdAt)} />
            <Field label="موعد تقریبی تحویل" value={formatDate(ticket.estimatedDeliveryAt)} />
          </div>

          <div className="space-y-1 py-1.5">
            {[
              { label: 'ایرادات', value: joinList(ticket.issues) },
              { label: 'متعلقات', value: joinList(ticket.accessories) },
              { label: 'توضیحات', value: ticket.customerNotes ?? '—' },
            ].map((row) => (
              <div key={row.label} className="flex items-start gap-1.5">
                <span className="mt-[1pt] inline-block h-[9pt] w-[9pt] shrink-0 border border-black" />
                <span className="text-[7pt] font-bold">{row.label}:</span>
                <span className="text-[7pt] leading-4">{row.value}</span>
              </div>
            ))}
          </div>

          <ol className="flex-1 list-decimal space-y-[1pt] pr-3 text-[5.6pt] leading-[8pt]">
            {RECEIPT_TERMS.map((term) => (
              <li key={term}>{term}</li>
            ))}
          </ol>

          <div className="border-t border-black pt-1">
            <p className="text-center text-[6.5pt] font-bold">
              سپردن دستگاه به این مرکز به منزله تایید کلیه مفاد بالا از جانب شما می‌باشد
            </p>
            <div className="mt-1 flex justify-between text-[7pt] font-bold">
              <span>مهر و امضای شرکت</span>
              <span>امضای مشتری</span>
            </div>
          </div>
        </section>

        {/* ---------- خط برش ---------- */}
        <div style={{ borderRight: '1px dashed #000' }} />

        {/* ---------- رسید تعمیرگاه (۱/۴) ---------- */}
        <aside className="flex flex-col gap-1" style={{ width: '48mm' }}>
          <div className="border-b border-black pb-1 text-center text-[8pt] font-black">
            قبض رسید تعمیرگاه
          </div>

          <div className="text-[8pt] font-bold leading-4">{ticket.customer.name}</div>
          <div className="text-[7pt] leading-4">{deviceTitle}</div>
          <div dir="ltr" className="text-right text-[7.5pt] font-bold">
            {ticket.customer.phone}
          </div>

          <div className="grid grid-cols-2 gap-x-1.5 gap-y-0.5 border-y border-gray-300 py-1">
            <Field label="شماره پذیرش" value={ticket.ticketNumber} />
            <Field label="تاریخ ورود" value={formatDate(ticket.createdAt)} />
            <Field label="موعد تحویل" value={formatDate(ticket.estimatedDeliveryAt)} />
            <Field label="هزینه تخمینی" value={formatPrice(ticket.estimatedCost)} />
            <Field label="شماره قفسه" value={ticket.shelfNumber ?? '—'} />
            <Field label="سریال" value={ticket.device.serial ?? '—'} />
            <Field label="پسورد" value={ticket.devicePassword ?? '—'} />
            <Field label="وضعیت" value="پذیرش جدید" />
          </div>

          <div className="space-y-1">
            <div>
              <div className="text-[6.5pt] text-gray-500">ایرادات</div>
              <div className="text-[7pt] font-bold leading-[9pt]">{joinList(ticket.issues)}</div>
            </div>
            <div>
              <div className="text-[6.5pt] text-gray-500">متعلقات</div>
              <div className="text-[7pt] leading-[9pt]">{joinList(ticket.accessories)}</div>
            </div>
            <div>
              <div className="text-[6.5pt] text-gray-500">توضیحات</div>
              <div className="text-[7pt] leading-[9pt]">{ticket.technicianNotes ?? '—'}</div>
            </div>
          </div>
        </aside>
      </div>
    </>
  );
}
