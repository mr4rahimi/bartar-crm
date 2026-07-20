'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowRight, Grid3x3, Loader2, Plus, Printer, Save } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { PriceInput } from '@/shared/components/ui/price-input';
import { PromptDialog } from '@/shared/components/ui/prompt-dialog';
import { ChipMultiSelect } from '@/shared/components/ui/chip-multi-select';
import { JalaliDateInput } from '@/shared/components/ui/jalali-date-input';
import { SearchableSelect } from '@/shared/components/ui/searchable-select';
import { PatternLockDialog } from '@/shared/components/ui/pattern-lock-dialog';
import { useToast } from '@/shared/components/providers/toast-provider';
// هوک‌های تاکسونومی مشترک‌اند (نوع دستگاه/برند/مدل)
import { useTaxonomy, useCreateModel } from '@/features/part-requests/hooks/use-taxonomy';
import { useQuickCreate } from '@/features/part-requests/hooks/use-quick-create';
import { CustomerPicker } from './customer-picker';
import {
  useReceptionCatalog,
  useCreateCatalogItem,
  useCreateTicket,
} from '../hooks/use-reception';
import type { CustomerDto } from '../types/ticket.types';

function Section({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <section className="rounded-lg border border-border bg-card p-4">
      <h2 className="mb-3 text-[13.5px] font-extrabold">{title}</h2>
      {children}
    </section>
  );
}

/** دکمه مربعی کنار فیلدها برای افزودن سریع */
function AddButton({ title, onClick }: { title: string; onClick: () => void }) {
  return (
    <button
      type="button"
      title={title}
      onClick={onClick}
      className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md border border-border bg-card text-primary hover:bg-muted"
    >
      <Plus className="h-4 w-4" />
    </button>
  );
}

export function ReceptionFormView() {
  const router = useRouter();
  const { toast } = useToast();

  const taxonomy = useTaxonomy();
  const createModel = useCreateModel();
  const quickCreate = useQuickCreate();
  const createTicket = useCreateTicket();

  const [customer, setCustomer] = useState<CustomerDto | null>(null);
  const [deviceTypeId, setDeviceTypeId] = useState('');
  const [brandId, setBrandId] = useState('');
  const [modelId, setModelId] = useState('');
  const [serial, setSerial] = useState('');
  const [devicePassword, setDevicePassword] = useState('');
  const [estimatedCost, setEstimatedCost] = useState('');
  const [deliveryAt, setDeliveryAt] = useState('');
  const [accessoryIds, setAccessoryIds] = useState<string[]>([]);
  const [issueIds, setIssueIds] = useState<string[]>([]);
  const [technicianNotes, setTechnicianNotes] = useState('');
  const [customerNotes, setCustomerNotes] = useState('');

  const [isPatternOpen, setIsPatternOpen] = useState(false);
  const [isBrandPromptOpen, setIsBrandPromptOpen] = useState(false);
  const [isModelPromptOpen, setIsModelPromptOpen] = useState(false);
  const [isAccessoryPromptOpen, setIsAccessoryPromptOpen] = useState(false);
  const [isIssuePromptOpen, setIsIssuePromptOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const catalog = useReceptionCatalog(deviceTypeId);
  const createAccessory = useCreateCatalogItem('accessories');
  const createIssue = useCreateCatalogItem('device-issues');

  const filteredModels = useMemo(() => {
    if (!taxonomy.data || !brandId) return [];
    return taxonomy.data.models
      .filter(
        (model) =>
          model.brandId === brandId &&
          (!deviceTypeId || model.deviceTypeId === deviceTypeId || model.deviceTypeId === null),
      )
      .map((model) => ({ id: model.id, name: model.name }));
  }, [taxonomy.data, brandId, deviceTypeId]);

  const toggle = (list: string[], setList: (value: string[]) => void, id: string) => {
    setList(list.includes(id) ? list.filter((item) => item !== id) : [...list, id]);
  };

  const addBrand = async (name: string) => {
    try {
      const created = await quickCreate.createBrand(name);
      setBrandId(created.id);
      setModelId('');
      toast('برند افزوده شد');
      setIsBrandPromptOpen(false);
    } catch (error) {
      toast(error instanceof Error ? error.message : 'خطا', 'error');
    }
  };

  const addModel = async (name: string) => {
    if (!deviceTypeId || !brandId) {
      toast('ابتدا نوع دستگاه و برند را انتخاب کنید', 'error');
      return;
    }
    try {
      const created = await createModel.mutateAsync({ name, deviceTypeId, brandId });
      setModelId(created.id);
      toast('مدل افزوده شد');
      setIsModelPromptOpen(false);
    } catch (error) {
      toast(error instanceof Error ? error.message : 'خطا', 'error');
    }
  };

  const submit = async (thenPrint: boolean) => {
    if (!customer) {
      toast('مشتری را انتخاب یا ثبت کنید', 'error');
      return;
    }
    if (!deviceTypeId || !brandId || !modelId) {
      toast('نوع دستگاه، برند و مدل را مشخص کنید', 'error');
      return;
    }

    setIsSaving(true);
    try {
      const ticket = await createTicket.mutateAsync({
        customerId: customer.id,
        deviceTypeId,
        brandId,
        modelId,
        serial: serial.trim() || undefined,
        devicePassword: devicePassword.trim() || undefined,
        estimatedCost: estimatedCost.trim() || undefined,
        estimatedDeliveryAt: deliveryAt || undefined,
        accessoryIds,
        issueIds,
        technicianNotes: technicianNotes.trim() || undefined,
        customerNotes: customerNotes.trim() || undefined,
      });

      toast(`قبض پذیرش #${ticket.ticketNumber} ثبت شد`);
      if (thenPrint) window.open(`/repairs/${ticket.id}/print`, '_blank');
      router.push('/repairs');
    } catch (error) {
      toast(error instanceof Error ? error.message : 'خطا در ثبت پذیرش', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  const today = new Date().toLocaleDateString('fa-IR');

  return (
    <div className="space-y-4 pb-4">
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => router.push('/repairs')}
          className="rounded-md p-1.5 text-muted-foreground hover:bg-muted"
          aria-label="بازگشت"
        >
          <ArrowRight className="h-5 w-5" />
        </button>
        <h1 className="flex-1 text-xl font-extrabold">قبض پذیرش جدید</h1>
        <span className="rounded-md bg-muted px-3 py-1.5 text-[12px] font-bold text-muted-foreground">
          تاریخ پذیرش: {today}
        </span>
      </div>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-2">
        <div className="space-y-4">
          <Section title="مشتری">
            <CustomerPicker value={customer} onChange={setCustomer} />
          </Section>

          <Section title="دستگاه">
            <div className="space-y-3">
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="deviceType">نوع دستگاه</Label>
                <SearchableSelect
                  id="deviceType"
                  items={taxonomy.data?.deviceTypes ?? []}
                  value={deviceTypeId}
                  onChange={(id) => {
                    setDeviceTypeId(id);
                    setModelId('');
                    setIssueIds([]);
                    setAccessoryIds([]);
                  }}
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="brand">برند</Label>
                <div className="flex gap-1.5">
                  <div className="flex-1">
                    <SearchableSelect
                      id="brand"
                      items={taxonomy.data?.brands ?? []}
                      value={brandId}
                      onChange={(id) => { setBrandId(id); setModelId(''); }}
                      createLabel="ثبت برند"
                      onCreate={addBrand}
                    />
                  </div>
                  <AddButton title="افزودن برند" onClick={() => setIsBrandPromptOpen(true)} />
                </div>
              </div>

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="model">مدل</Label>
                <div className="flex gap-1.5">
                  <div className="flex-1">
                    <SearchableSelect
                      id="model"
                      items={filteredModels}
                      value={modelId}
                      onChange={setModelId}
                      disabled={!brandId}
                      placeholder={brandId ? 'جستجو یا ثبت مدل…' : 'ابتدا برند را انتخاب کنید'}
                      emptyText="مدلی برای این برند ثبت نشده"
                      isCreating={createModel.isPending}
                      createLabel="ثبت مدل"
                      onCreate={addModel}
                    />
                  </div>
                  <AddButton title="افزودن مدل" onClick={() => setIsModelPromptOpen(true)} />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="serial">سریال دستگاه</Label>
                  <Input
                    id="serial"
                    dir="ltr"
                    className="text-right"
                    value={serial}
                    onChange={(event) => setSerial(event.target.value)}
                  />
                </div>
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="devicePassword">پسورد دستگاه</Label>
                  <div className="flex gap-1.5">
                    <Input
                      id="devicePassword"
                      dir="ltr"
                      className="text-right"
                      placeholder="رمز یا الگو"
                      value={devicePassword}
                      onChange={(event) => setDevicePassword(event.target.value)}
                    />
                    <button
                      type="button"
                      title="رسم الگوی قفل"
                      onClick={() => setIsPatternOpen(true)}
                      className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md border border-border bg-card text-primary hover:bg-muted"
                    >
                      <Grid3x3 className="h-4 w-4" />
                    </button>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="estimatedCost">هزینه تقریبی (تومان)</Label>
                  <PriceInput id="estimatedCost" value={estimatedCost} onChange={setEstimatedCost} />
                </div>
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="deliveryAt">موعد تقریبی تحویل</Label>
                  <JalaliDateInput
                    id="deliveryAt"
                    value={deliveryAt}
                    onChange={setDeliveryAt}
                    placeholder="انتخاب تاریخ"
                  />
                </div>
              </div>
            </div>
          </Section>
        </div>

        <div className="space-y-4">
          <Section title="ایرادات">
            {deviceTypeId ? (
              <ChipMultiSelect
                items={catalog.data?.issues ?? []}
                selectedIds={issueIds}
                onToggle={(id) => toggle(issueIds, setIssueIds, id)}
                onAdd={() => setIsIssuePromptOpen(true)}
              />
            ) : (
              <p className="py-3 text-center text-[12.5px] text-muted-foreground">
                ابتدا نوع دستگاه را انتخاب کنید
              </p>
            )}
          </Section>

          <Section title="متعلقات">
            {deviceTypeId ? (
              <ChipMultiSelect
                items={catalog.data?.accessories ?? []}
                selectedIds={accessoryIds}
                onToggle={(id) => toggle(accessoryIds, setAccessoryIds, id)}
                onAdd={() => setIsAccessoryPromptOpen(true)}
              />
            ) : (
              <p className="py-3 text-center text-[12.5px] text-muted-foreground">
                ابتدا نوع دستگاه را انتخاب کنید
              </p>
            )}
          </Section>

          <Section title="توضیحات">
            <div className="space-y-3">
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="technicianNotes">توضیحات تعمیرکار</Label>
                <Textarea
                  id="technicianNotes"
                  rows={2}
                  placeholder="در قبض مشتری چاپ نمی‌شود"
                  value={technicianNotes}
                  onChange={(event) => setTechnicianNotes(event.target.value)}
                />
              </div>
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="customerNotes">توضیحات برای مشتری</Label>
                <Textarea
                  id="customerNotes"
                  rows={2}
                  placeholder="در قبض مشتری چاپ می‌شود"
                  value={customerNotes}
                  onChange={(event) => setCustomerNotes(event.target.value)}
                />
              </div>
            </div>
          </Section>
        </div>
      </div>

      <div className="sticky bottom-[calc(4rem+env(safe-area-inset-bottom))] z-10 flex gap-2 rounded-lg border border-border bg-card p-3 md:bottom-4">
        <Button
          variant="outline"
          className="h-12 flex-1 text-[13.5px]"
          disabled={isSaving}
          onClick={() => submit(false)}
        >
          {isSaving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Save className="h-4 w-4" />}
          ذخیره و بستن
        </Button>
        <Button
          className="h-12 flex-1 text-[13.5px]"
          disabled={isSaving}
          onClick={() => submit(true)}
        >
          {isSaving ? <Loader2 className="h-4 w-4 animate-spin" /> : <Printer className="h-4 w-4" />}
          ذخیره و چاپ
        </Button>
      </div>

      <PatternLockDialog
        open={isPatternOpen}
        onClose={() => setIsPatternOpen(false)}
        onSubmit={setDevicePassword}
      />

      <PromptDialog
        open={isBrandPromptOpen}
        title="افزودن برند جدید"
        label="نام برند"
        placeholder="مثلاً: Nokia"
        onClose={() => setIsBrandPromptOpen(false)}
        onSubmit={addBrand}
      />

      <PromptDialog
        open={isModelPromptOpen}
        title="افزودن مدل جدید"
        label="نام مدل"
        placeholder="مثلاً: Galaxy A55"
        isPending={createModel.isPending}
        onClose={() => setIsModelPromptOpen(false)}
        onSubmit={addModel}
      />

      <PromptDialog
        open={isIssuePromptOpen}
        title="افزودن ایراد جدید"
        label="عنوان ایراد"
        isPending={createIssue.isPending}
        onClose={() => setIsIssuePromptOpen(false)}
        onSubmit={(name) => {
          createIssue.mutate(
            { name, deviceTypeId },
            {
              onSuccess: (item) => {
                setIssueIds((current) => [...current, item.id]);
                toast('ایراد افزوده شد');
                setIsIssuePromptOpen(false);
              },
              onError: (error) => toast(error.message, 'error'),
            },
          );
        }}
      />

      <PromptDialog
        open={isAccessoryPromptOpen}
        title="افزودن متعلقات جدید"
        label="عنوان متعلقات"
        isPending={createAccessory.isPending}
        onClose={() => setIsAccessoryPromptOpen(false)}
        onSubmit={(name) => {
          createAccessory.mutate(
            { name, deviceTypeId },
            {
              onSuccess: (item) => {
                setAccessoryIds((current) => [...current, item.id]);
                toast('متعلقات افزوده شد');
                setIsAccessoryPromptOpen(false);
              },
              onError: (error) => toast(error.message, 'error'),
            },
          );
        }}
      />
    </div>
  );
}
