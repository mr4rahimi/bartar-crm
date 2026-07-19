'use client';

import { useState } from 'react';
import { Loader2, Search, UserPlus, X } from 'lucide-react';
import type { CustomerTitle } from '@prisma/client';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { Button } from '@/shared/components/ui/button';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { cn } from '@/shared/lib/cn';
import { useCustomerSearch, useCreateCustomer } from '../hooks/use-reception';
import type { CustomerDto } from '../types/ticket.types';

const TITLES: { value: CustomerTitle; label: string }[] = [
  { value: 'MR', label: 'آقای' },
  { value: 'MRS', label: 'خانم' },
  { value: 'COMPANY', label: 'شرکت' },
];

type CustomerPickerProps = {
  value: CustomerDto | null;
  onChange: (customer: CustomerDto | null) => void;
};

export function CustomerPicker({ value, onChange }: CustomerPickerProps) {
  const { toast } = useToast();
  const createCustomer = useCreateCustomer();

  const [search, setSearch] = useState('');
  const [isCreating, setIsCreating] = useState(false);
  const debouncedSearch = useDebouncedValue(search, 300);
  const results = useCustomerSearch(debouncedSearch);

  const [title, setTitle] = useState<CustomerTitle>('MR');
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [companyName, setCompanyName] = useState('');
  const [nationalCode, setNationalCode] = useState('');
  const [postalCode, setPostalCode] = useState('');
  const [phone, setPhone] = useState('');
  const [secondaryPhone, setSecondaryPhone] = useState('');
  const [address, setAddress] = useState('');

  const isCompany = title === 'COMPANY';

  const handleCreate = () => {
    createCustomer.mutate(
      {
        title,
        firstName: isCompany ? undefined : firstName.trim(),
        lastName: isCompany ? undefined : lastName.trim(),
        companyName: isCompany ? companyName.trim() : undefined,
        nationalCode: nationalCode.trim() || undefined,
        postalCode: postalCode.trim() || undefined,
        phone: phone.trim(),
        secondaryPhone: secondaryPhone.trim() || undefined,
        address: address.trim() || undefined,
      },
      {
        onSuccess: (customer) => {
          toast('مشتری ثبت شد');
          onChange(customer);
          setIsCreating(false);
          setSearch('');
        },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  // ---- حالت ۱: مشتری انتخاب شده ----
  if (value) {
    return (
      <div className="rounded-lg border border-primary bg-accent p-3.5">
        <div className="flex items-start justify-between gap-2">
          <div>
            <div className="text-[14px] font-extrabold text-accent-foreground">{value.name}</div>
            <div dir="ltr" className="mt-1 text-right text-[12.5px] text-accent-foreground/80">
              {value.phone}
              {value.secondaryPhone && ` — ${value.secondaryPhone}`}
            </div>
            {value.address && (
              <div className="mt-1 text-[11.5px] text-accent-foreground/70">{value.address}</div>
            )}
          </div>
          <button
            type="button"
            onClick={() => onChange(null)}
            className="rounded-md p-1 text-accent-foreground/70 hover:bg-background/40"
            aria-label="تغییر مشتری"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      </div>
    );
  }

  // ---- حالت ۲: فرم مشتری جدید ----
  if (isCreating) {
    return (
      <div className="space-y-3 rounded-lg border border-border bg-background p-3.5">
        <div className="flex items-center justify-between">
          <span className="text-[13px] font-extrabold">ثبت مشتری جدید</span>
          <button
            type="button"
            onClick={() => setIsCreating(false)}
            className="rounded-md p-1 text-muted-foreground hover:bg-muted"
            aria-label="انصراف"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="flex gap-2">
          {TITLES.map((item) => (
            <button
              key={item.value}
              type="button"
              onClick={() => setTitle(item.value)}
              className={cn(
                'flex-1 rounded-md border px-3 py-2.5 text-[13px] font-bold',
                title === item.value
                  ? 'border-primary bg-accent text-accent-foreground'
                  : 'border-border bg-card text-muted-foreground',
              )}
            >
              {item.label}
            </button>
          ))}
        </div>

        {isCompany ? (
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="companyName">نام فروشگاه / شرکت</Label>
            <Input
              id="companyName"
              value={companyName}
              onChange={(event) => setCompanyName(event.target.value)}
            />
          </div>
        ) : (
          <div className="grid grid-cols-2 gap-2.5">
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="firstName">نام</Label>
              <Input
                id="firstName"
                value={firstName}
                onChange={(event) => setFirstName(event.target.value)}
              />
            </div>
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="lastName">نام خانوادگی</Label>
              <Input
                id="lastName"
                value={lastName}
                onChange={(event) => setLastName(event.target.value)}
              />
            </div>
          </div>
        )}

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="phone">شماره همراه</Label>
            <Input
              id="phone"
              dir="ltr"
              className="text-right"
              inputMode="numeric"
              value={phone}
              onChange={(event) => setPhone(event.target.value)}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="secondaryPhone">شماره تماس دوم</Label>
            <Input
              id="secondaryPhone"
              dir="ltr"
              className="text-right"
              inputMode="numeric"
              value={secondaryPhone}
              onChange={(event) => setSecondaryPhone(event.target.value)}
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="nationalCode">
              {isCompany ? 'شناسه ملی' : 'کد ملی'}
            </Label>
            <Input
              id="nationalCode"
              dir="ltr"
              className="text-right"
              inputMode="numeric"
              value={nationalCode}
              onChange={(event) => setNationalCode(event.target.value)}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="postalCode">کد پستی</Label>
            <Input
              id="postalCode"
              dir="ltr"
              className="text-right"
              inputMode="numeric"
              value={postalCode}
              onChange={(event) => setPostalCode(event.target.value)}
            />
          </div>
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="address">آدرس</Label>
          <Textarea
            id="address"
            rows={2}
            value={address}
            onChange={(event) => setAddress(event.target.value)}
          />
        </div>

        <Button onClick={handleCreate} disabled={createCustomer.isPending}>
          {createCustomer.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ثبت مشتری
        </Button>
      </div>
    );
  }

  // ---- حالت ۳: جستجو ----
  return (
    <div className="space-y-2">
      <div className="relative">
        <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          className="pr-9"
          placeholder="جستجوی شماره همراه یا نام مشتری…"
          value={search}
          onChange={(event) => setSearch(event.target.value)}
        />
      </div>

      {debouncedSearch.trim().length >= 2 && (
        <div className="max-h-52 overflow-y-auto rounded-md border border-border bg-card">
          {results.isLoading && (
            <p className="px-3.5 py-3 text-[12.5px] text-muted-foreground">در حال جستجو…</p>
          )}
          {results.data?.map((customer) => (
            <button
              key={customer.id}
              type="button"
              onClick={() => onChange(customer)}
              className="block w-full border-b border-border px-3.5 py-2.5 text-right last:border-b-0 hover:bg-muted"
            >
              <span className="text-[13px] font-bold">{customer.name}</span>
              <span dir="ltr" className="mr-2 text-[11.5px] text-muted-foreground">
                {customer.phone}
              </span>
            </button>
          ))}
          {results.data?.length === 0 && !results.isLoading && (
            <p className="px-3.5 py-3 text-[12.5px] text-muted-foreground">
              مشتری‌ای یافت نشد — می‌توانید مشتری جدید ثبت کنید
            </p>
          )}
        </div>
      )}

      <button
        type="button"
        onClick={() => {
          setIsCreating(true);
          // اگر ورودی جستجو شماره بود، پیش‌پر شود
          if (/^[0-9۰-۹]+$/.test(search.trim())) setPhone(search.trim());
        }}
        className="flex w-full items-center justify-center gap-1.5 rounded-md border border-dashed border-primary py-2.5 text-[13px] font-bold text-primary"
      >
        <UserPlus className="h-4 w-4" />
        ثبت مشتری جدید
      </button>
    </div>
  );
}
