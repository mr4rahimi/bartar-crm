'use client';

import { forwardRef } from 'react';
import { cn } from '@/shared/lib/cn';
import { normalizeDigits } from '@/shared/lib/normalize';

const FA_DIGITS = '۰۱۲۳۴۵۶۷۸۹';

// نمایش سه‌رقم‌سه‌رقم با ارقام فارسی؛ مقدار خروجی همیشه رشته‌ی خام لاتین است
function formatForDisplay(rawLatin: string): string {
  if (!rawLatin) return '';
  const grouped = rawLatin.replace(/\B(?=(\d{3})+(?!\d))/g, '٬');
  return grouped.replace(/\d/g, (digit) => FA_DIGITS[Number(digit)] ?? digit);
}

type PriceInputProps = {
  value: string;
  onChange: (rawValue: string) => void;
  id?: string;
  placeholder?: string;
  className?: string;
  disabled?: boolean;
};

export const PriceInput = forwardRef<HTMLInputElement, PriceInputProps>(
  ({ value, onChange, id, placeholder, className, disabled }, ref) => {
    const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
      // فقط ارقام را نگه می‌داریم (ورودی فارسی/عربی هم نرمال می‌شود)
      const rawLatin = normalizeDigits(event.target.value).replace(/[^\d]/g, '');
      onChange(rawLatin);
    };

    return (
      <input
        ref={ref}
        id={id}
        type="text"
        inputMode="numeric"
        dir="ltr"
        placeholder={placeholder}
        disabled={disabled}
        value={formatForDisplay(value)}
        onChange={handleChange}
        className={cn(
          'flex h-11 w-full rounded-md border border-input bg-background px-3 text-right text-sm placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 disabled:opacity-50',
          className,
        )}
      />
    );
  },
);
PriceInput.displayName = 'PriceInput';
