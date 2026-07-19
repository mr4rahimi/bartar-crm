'use client';

import { useEntityLogs } from '../hooks/use-entity-logs';
import {
  LOG_ACTION_LABELS,
  LOG_FIELD_LABELS,
  formatLogValue,
} from '../constants/log-labels.constants';

export function RequestLogList({ requestId, enabled }: { requestId: string; enabled: boolean }) {
  const logs = useEntityLogs('PartRequest', requestId, enabled);

  if (!enabled) return null;

  return (
    <div className="rounded-lg border border-border bg-card p-4">
      <h2 className="mb-3 text-sm font-extrabold">تاریخچه تغییرات</h2>

      {logs.isLoading && (
        <p className="py-4 text-center text-[12.5px] text-muted-foreground">در حال بارگذاری…</p>
      )}

      {logs.data?.length === 0 && (
        <p className="py-4 text-center text-[12.5px] text-muted-foreground">تغییری ثبت نشده</p>
      )}

      <div className="space-y-2">
        {logs.data?.map((log) => {
          const changedFields = Object.keys(log.newValue ?? {});
          return (
            <div key={log.id} className="rounded-md border border-border bg-background p-3">
              <div className="flex items-center justify-between">
                <span className="text-[12.5px] font-extrabold">
                  {LOG_ACTION_LABELS[log.action] ?? log.action}
                </span>
                <span className="text-[11px] text-muted-foreground">
                  {log.userName} — {new Date(log.createdAt).toLocaleString('fa-IR')}
                </span>
              </div>

              {changedFields.length > 0 && (
                <ul className="mt-1.5 space-y-1">
                  {changedFields.map((field) => (
                    <li key={field} className="text-[11.5px] leading-5">
                      <span className="font-bold">{LOG_FIELD_LABELS[field] ?? field}:</span>{' '}
                      <span className="text-muted-foreground line-through">
                        {formatLogValue(field, log.previousValue?.[field])}
                      </span>{' '}
                      <span className="text-primary">
                        ← {formatLogValue(field, log.newValue?.[field])}
                      </span>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          );
        })}
      </div>
    </div>
  );
}
