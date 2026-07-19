'use client';

import { cn } from '@/shared/lib/cn';
import {
  CHANGELOG,
  CHANGE_TYPE_LABELS,
  APP_VERSION,
  type ChangeType,
} from '@/shared/constants/changelog';

const TYPE_CLASSES: Record<ChangeType, string> = {
  added: 'bg-[#eafaf0] text-[#15803d] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
  changed: 'bg-[#eaf1fe] text-[#1d4ed8] dark:bg-[#122236] dark:text-[#60a5fa]',
  fixed: 'bg-[#fef9e7] text-[#92730c] dark:bg-[#332b0f] dark:text-[#fbbf24]',
  security: 'bg-[#fdecec] text-[#b91c1c] dark:bg-[#341313] dark:text-[#f87171]',
};

function formatDate(value: string) {
  return new Date(value).toLocaleDateString('fa-IR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
  });
}

export function AboutView() {
  return (
    <div className="space-y-4">
      <div className="rounded-lg border border-border bg-card p-5">
        <div className="flex items-center gap-3">
          <div className="flex h-11 w-11 items-center justify-center rounded-xl bg-primary text-lg font-extrabold text-primary-foreground">
            ب
          </div>
          <div>
            <h1 className="text-lg font-extrabold">برتر CRM</h1>
            <p className="text-[12px] text-muted-foreground">
              سامانه مدیریت درخواست قطعه، خرید و اعلام هزینه
            </p>
          </div>
          <span className="mr-auto rounded-lg bg-accent px-3 py-1.5 text-[13px] font-extrabold text-accent-foreground">
            نسخه {APP_VERSION}
          </span>
        </div>
      </div>

      <h2 className="px-1 text-[14px] font-extrabold">تاریخچه تغییرات</h2>

      <div className="space-y-3">
        {CHANGELOG.map((release, index) => (
          <div key={release.version} className="rounded-lg border border-border bg-card p-4">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-[15px] font-extrabold">{release.version}</span>
              {index === 0 && (
                <span className="rounded-full bg-primary px-2.5 py-0.5 text-[10.5px] font-bold text-primary-foreground">
                  نسخه فعلی
                </span>
              )}
              <span className="text-[11.5px] text-muted-foreground">
                {formatDate(release.date)}
              </span>
            </div>
            <div className="mt-0.5 text-[12.5px] font-bold text-muted-foreground">
              {release.title}
            </div>

            <ul className="mt-3 space-y-2">
              {release.changes.map((change) => (
                <li key={change.text} className="flex items-start gap-2">
                  <span
                    className={cn(
                      'mt-0.5 shrink-0 rounded-md px-2 py-0.5 text-[10.5px] font-bold',
                      TYPE_CLASSES[change.type],
                    )}
                  >
                    {CHANGE_TYPE_LABELS[change.type]}
                  </span>
                  <span className="text-[12.5px] leading-6">{change.text}</span>
                </li>
              ))}
            </ul>
          </div>
        ))}
      </div>
    </div>
  );
}
