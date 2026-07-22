'use client';

import { CheckCircle2, XCircle } from 'lucide-react';
import { useQualityChecks } from '../hooks/use-quality-checks';

export function QualityCheckList({ ticketId }: { ticketId: string }) {
  const query = useQualityChecks(ticketId);

  if (query.isLoading) {
    return <p className="py-3 text-center text-[12px] text-muted-foreground">در حال بارگذاری…</p>;
  }

  if (!query.data || query.data.length === 0) {
    return (
      <p className="py-3 text-center text-[12px] text-muted-foreground">
        کنترل کیفیتی ثبت نشده
      </p>
    );
  }

  return (
    <div className="space-y-2">
      {query.data.map((check) => (
        <div key={check.id} className="rounded-md border border-border bg-background px-3 py-2.5">
          <div className="flex items-center gap-1.5">
            {check.passed ? (
              <CheckCircle2 className="h-4 w-4 text-[#15803d] dark:text-[#4ade80]" />
            ) : (
              <XCircle className="h-4 w-4 text-destructive" />
            )}
            <span className="text-[12.5px] font-bold">
              {check.passed ? 'تایید کیفیت' : 'رد کیفیت'}
            </span>
          </div>
          <p className="mt-1 whitespace-pre-wrap text-[12px] leading-6">{check.notes}</p>
          <div className="mt-1.5 flex items-center gap-2 text-[10.5px] text-muted-foreground">
            <span className="font-bold">{check.checkedByName}</span>
            <span>{new Date(check.createdAt).toLocaleString('fa-IR')}</span>
          </div>
        </div>
      ))}
    </div>
  );
}
