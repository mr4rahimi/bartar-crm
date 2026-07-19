'use client';

import { useEffect, useState } from 'react';
import DatePicker, { type DateObject } from 'react-multi-date-picker';
import persian from 'react-date-object/calendars/persian';
import persian_fa from 'react-date-object/locales/persian_fa';

type JalaliDateInputProps = {
  /** ISO string */
  value: string;
  onChange: (isoValue: string) => void;
  id?: string;
  placeholder?: string;
};

export function JalaliDateInput({ value, onChange, id, placeholder }: JalaliDateInputProps) {
  const [isDark, setIsDark] = useState(false);

  useEffect(() => {
    setIsDark(document.documentElement.classList.contains('dark'));
  }, []);

  return (
    <DatePicker
      id={id}
      calendar={persian}
      locale={persian_fa}
      calendarPosition="bottom-right"
      portal
      className={isDark ? 'bg-dark' : ''}
      containerClassName="w-full"
      inputClass="flex h-11 w-full rounded-md border border-input bg-background px-3 text-right text-sm focus-visible:outline-none focus-visible:ring-2"
      placeholder={placeholder}
      value={value ? new Date(value) : ''}
      onChange={(date) => {
        const selected = date as DateObject | null;
        onChange(selected ? selected.toDate().toISOString() : '');
      }}
    />
  );
}
