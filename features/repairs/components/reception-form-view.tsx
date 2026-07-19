'use client';

import { useMemo, useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowRight, Loader2, Printer, Save } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Select } from '@/shared/components/ui/select';
import { Textarea } from '@/shared/components/ui/textarea';
import { PriceInput } from '@/shared/components/ui/price-input';
import { PromptDialog } from '@/shared/components/ui/prompt-dialog';
import { ChipMultiSelect } from '@/shared/components/ui/chip-multi-select';
import { JalaliDateInput } from '@/shared/components/ui/jalali-date-input';
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
  const [modelName, setModelName] = useState('');
  const [serial, setSerial] = useState('');
  const [devicePassword, setDevicePassword] = useState('');
  const [estimatedCost, setEstimatedCost] = useState('');
  const [deliveryAt, setDeliveryAt] = useState('');
  const [accessoryIds, setAccessoryIds] = useState<string[]>([]);
  const [issueIds, setIssueIds] = useState<string[]>([]);
  const [technicianNotes, setTechnicianNotes] = useState('');
  const [customerNotes, setCustomerNotes] = useState('');

  const [isBrandPromptOpen, setIsBrandPromptOpen] = useState(false);
  const [isAccessoryPromptOpen, setIsAccessoryPromptOpen] = useState(false);
  const [isIssuePromptOpen, setIsIssuePromptOpen] = useState(false);
  const [isSaving, setIsSaving] = useState(false);

  const catalog = useReceptionCatalog(deviceTypeId);
  const createAccessory = useCreateCatalogItem('accessories');
  const createIssue = useCreateCatalogItem('device-issues');

  const filteredModels = useMemo(() => {
    if (!taxonomy.data || !brandId) return [];
    return taxonomy.data.models.filter(
      (model) =>
        model.brandId === brandId &&
        (!deviceTypeId || model.deviceTypeId === deviceTypeId || model.deviceTypeId === null),
    );
  }, [taxonomy.data, brandId, deviceTypeId]);

  const matchedModel = filteredModels.find((model) => model.name.trim() === modelName.trim());
  const isNewModel = Boolean(modelName.trim() && brandId && !matchedModel);

  const toggle = (list: string[], setList: (value: string[]) => void, id: string) => {
    setList(list.includes(id) ? list.filter((item) => item !== id) : [...list, id]);
  };

  const submit = async (thenPrint: boolean) => {
    if (!customer) {
      toast('مشتری را انتخاب یا ثبت کنید', 'error');
      return;
    }
    if (!deviceTypeId || !brandId || !modelName.trim()) {
      toast('نوع دستگاه، برند و مدل را مشخص کنید', 'error');
      return;
    }

    setIsSaving(true);
    try {
      let modelId = matchedModel?.id;
      if (!modelId) {
        const created = await createModel.mutateAsync({
          name: modelName.trim(),
          deviceTypeId,
          brandId,
        });
        modelId = created.id;
      }

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
      router.push(thenPrint ? `/repairs/${ticket.id}/print` : '/repairs');
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
              <div className="grid grid-cols-2 gap-2.5">
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="deviceType">نوع دستگاه</Label>
                  <Select
                    id="deviceType"
                    value={deviceTypeId}
                    onChange={(event) => {
                      setDeviceTypeId(event.target.value);
                      setModelName('');
                      setIssueIds([]);
                      setAccessoryIds([]);
                    }}
                  >
                    <option value="">انتخاب کنید…</option>
                    {taxonomy.data?.deviceTypes.map((type) => (
                      <option key={type.id} value={type.id}>{type.name}</option>
                    ))}
                  </Select>
                </div>
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="brand">برند</Label>
                  <div className="flex gap-1.5">
                    <Select
                      id="brand"
                      value={brandId}
                      onChange={(event) => { setBrandId(event.target.value); setModelName(''); }}
                    >
                      <option value="">انتخاب کنید…</option>
                      {taxonomy.data?.brands.map((brand) => (
                        <option key={brand.id} value={brand.id}>{brand.name}</option>
                      ))}
                    </Select>
                    <button
                      type="button"
                      title="افزودن برند"
                      onClick={() => setIsBrandPromptOpen(true)}
                      className="flex h-11 w-11 shrink-0 items-center justify-center rounded-md border border-border bg-card text-lg font-bold text-primary"
                    >
                      +
                    </button>
                  </div>
                </div>
              </div>

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="model">مدل</Label>
                <Input
                  id="model"
                  list="reception-model-options"
                  placeholder="جستجو یا ورود مدل جدید…"
                  value={modelName}
                  disabled={!brandId}
                  onChange={(event) => setModelName(event.target.value)}
                />
                <datalist id="reception-model-options">
                  {filteredModels.map((model) => <option key={model.id} value={model.name} />)}
                </datalist>
                {isNewModel && (
                  <p className="text-[11px] font-semibold text-accent-foreground">
                    مدل «{modelName.trim()}» جدید است و هنگام ثبت اضافه می‌شود.
                  </p>
                )}
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
                  <Input
                    id="devicePassword"
                    value={devicePassword}
                    onChange={(event) => setDevicePassword(event.target.value)}
                  />
                </div>
              </div>

              <div className="grid grid-cols-2 gap-2.5">
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="estimatedCost">هزینه تقریبی (تومان)</Label>
                  <PriceInput
                    id="estimatedCost"
                    value={estimatedCost}
                    onChange={setEstimatedCost}
                  />
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

      <PromptDialog
        open={isBrandPromptOpen}
        title="افزودن برند جدید"
        label="نام برند"
        onClose={() => setIsBrandPromptOpen(false)}
        onSubmit={async (name) => {
          try {
            const created = await quickCreate.createBrand(name);
            setBrandId(created.id);
            setModelName('');
            toast('برند افزوده شد');
            setIsBrandPromptOpen(false);
          } catch (error) {
            toast(error instanceof Error ? error.message : 'خطا', 'error');
          }
        }}
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
