import type { PartRequestStatus } from '@prisma/client';
import { cn } from '@/shared/lib/cn';
import {
  PART_REQUEST_STATUS_LABELS,
  PART_REQUEST_STATUS_FAMILY,
  type StatusFamily,
} from '@/shared/constants/part-request-status';

// رنگ‌ها از FAMILY_COLORS ماکاپ ui/ (روشن/تیره)
const FAMILY_CLASSES: Record<StatusFamily, string> = {
  gray: 'bg-[#f1f2f4] text-[#52525b] dark:bg-[#26282d] dark:text-[#a1a1aa]',
  yellow: 'bg-[#fef9e7] text-[#92730c] dark:bg-[#332b0f] dark:text-[#fbbf24]',
  blue: 'bg-[#eaf1fe] text-[#1d4ed8] dark:bg-[#122236] dark:text-[#60a5fa]',
  green: 'bg-[#eafaf0] text-[#15803d] dark:bg-[#0f2b1c] dark:text-[#4ade80]',
  red: 'bg-[#fdecec] text-[#b91c1c] dark:bg-[#341313] dark:text-[#f87171]',
  orange: 'bg-[#fef1e6] text-[#c2410c] dark:bg-[#33200f] dark:text-[#fb923c]',
  dark: 'bg-[#e6e7eb] text-[#27272a] dark:bg-[#1c1d21] dark:text-[#d4d4d8]',
};

export function StatusChip({
  status,
  className,
}: {
  status: PartRequestStatus;
  className?: string;
}) {
  return (
    <span
      className={cn(
        'inline-flex items-center whitespace-nowrap rounded-full px-2.5 py-1 text-[11px] font-bold',
        FAMILY_CLASSES[PART_REQUEST_STATUS_FAMILY[status]],
        className,
      )}
    >
      {PART_REQUEST_STATUS_LABELS[status]}
    </span>
  );
}
