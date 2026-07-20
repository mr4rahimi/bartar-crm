'use client';

import { useEffect, useMemo, useState } from 'react';
import { Grid3x3, Loader2 } from 'lucide-react';
import type { RepairTicketStatus } from '@prisma/client';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { PriceInput } from '@/shared/components/ui/price-input';
import { SearchableSelect } from '@/shared/components/ui/searchable-select';
import { JalaliDateInput } from '@/shared/components/ui/jalali-date-input';
import { ChipMultiSelect } from '@/shared/components/ui/chip-multi-select';
import { PatternLockDialog } from '@/shared/components/ui/pattern-lock-dialog';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useTaxonomy } from '@/features/part-requests/hooks/use-taxonomy';
import { useReceptionCatalog } from '../hooks/use-reception';
import { useUpdateTicket } from '../hooks/use-ticket-mutations';
import { CustomerPicker } from './customer-picker';
import { TICKET_STATUS_LABELS, TICKET_STATUSES } from '../constants/ticket-status.constants';
import type { TicketDto, CustomerDto } from '../types/ticket.types';

type TicketEditDialogProps = {
  ticket: TicketDto | null;
  onClose: () => void;
};

export function TicketEditDialog({ ticket, onClose }: TicketEditDialogProps) {
  const { toast } = useToast();
  const updateTicket = useUpdateTicket();
  const taxonomy = useTaxonomy();

  const [customer, setCustomer] = useState<CustomerDto | null>(null);
  const [brandId, setBrandId] = useState('');
  const [modelId, setModelId] = useState('');
  const [serial, setSerial] = useState('');
  const [devicePassword, setDevicePassword] = useState('');
  const [shelfNumber, setShelfNumber] = useState('');
  const [estimatedCost, setEstimatedCost] = useState('');
  const [deliveryAt, setDeliveryAt] = useState('');
  const [status, setStatus] = useState<RepairTicketStatus>('OPEN');
  const [accessoryIds, setAccessoryIds] = useState<string[]>([]);
  const [issueIds, setIssueIds] = useState<string[]>([]);
  const [technicianNotes, setTechnicianNotes] = useState('');
  const [customerNotes, setCustomerNotes] = useState('');
  const [isPatternOpen, setIsPatternOpen] = useState(false);

  const catalog = useReceptionCatalog(ticket?.device.deviceTypeId ?? '');

  useEffect(() => {
    if (!ticket) return;
    setCustomer(ticket.customer);
    setBrandId(ticket.device.brandId);
    setModelId(ticket.device.modelId);
    setSerial(ticket.device.serial ?? '');
    setDevicePassword(ticket.devicePassword ?? '');
    setShelfNumber(ticket.shelfNumber ?? '');
    setEstimatedCost(ticket.estimatedCost != null ? String(ticket.estimatedCost) : '');
    setDeliveryAt(ticket.estimatedDeliveryAt ? new Date(ticket.estimatedDeliveryAt).toISOString() : '');
    setStatus(ticket.status);
    setAccessoryIds(ticket.accessoryIds);
    setIssueIds(ticket.issueIds);
    setTechnicianNotes(ticket.technicianNotes ?? '');
    setCustomerNotes(ticket.customerNotes ?? '');
  }, [ticket]);

  const filteredModels = useMemo(() => {
    if (!taxonomy.data || !brandId) return [];
    return taxonomy.data.models
      .filter((model) => model.brandId === brandId)
      .map((model) => ({ id: model.id, name: model.name }));
  }, [taxonomy.data, brandId]);

  if (!ticket) return null;

  const toggle = (list: string[], setList: (value: string[]) => void, id: string) => {
    setList(list.includes(id) ? list.filter((item) => item !== id) : [...list, id]);
  };

  const handleSubmit = () => {
    if (!customer || !brandId || !modelId) {
      toast('مشتری، برند و مدل الزامی است', 'error');
      return;
    }

    updateTicket.mutate(
      {
        ticketId: ticket.id,
        customerId: customer.id,
        brandId,
        modelId,
        serial: serial.trim() || null,
        devicePassword: devicePassword.trim() || null,
        shelfNumber: shelfNumber.trim() || null,
        estimatedCost: estimatedCost.trim() || null,
        estimatedDeliveryAt: deliveryAt || null,
        status,
        accessoryIds,
        issueIds,
        technicianNotes: technicianNotes.trim() || null,
        customerNotes: customerNotes.trim() || null,
      },
      {
        onSuccess: () => { toast('قبض پذیرش ویرایش شد'); onClose(); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  return (
    <Dialog open onClose={onClose} title={`ویرایش قبض #${ticket.ticketNumber}`}>
      <div className="flex flex-col gap-3.5">
        <div>
          <Label className="mb-1.5 block">مشتری</Label>
          <CustomerPicker value={customer} onChange={setCustomer} />
        </div>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editBrand">برند</Label>
            <SearchableSelect
              id="editBrand"
              items={taxonomy.data?.brands ?? []}
              value={brandId}
              onChange={(id) => { setBrandId(id); setModelId(''); }}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editModel">مدل</Label>
            <SearchableSelect
              id="editModel"
              items={filteredModels}
              value={modelId}
              onChange={setModelId}
              disabled={!brandId}
              emptyText="مدلی برای این برند نیست"
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editSerial">سریال</Label>
            <Input
              id="editSerial"
              dir="ltr"
              className="text-right"
              value={serial}
              onChange={(event) => setSerial(event.target.value)}
            />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editPassword">پسورد دستگاه</Label>
            <div className="flex gap-1.5">
              <Input
                id="editPassword"
                dir="ltr"
                className="text-right"
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
            <Label htmlFor="editCost">هزینه تقریبی</Label>
            <PriceInput id="editCost" value={estimatedCost} onChange={setEstimatedCost} />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editShelf">شماره قفسه</Label>
            <Input
              id="editShelf"
              value={shelfNumber}
              onChange={(event) => setShelfNumber(event.target.value)}
            />
          </div>
        </div>

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editDelivery">موعد تحویل</Label>
            <JalaliDateInput id="editDelivery" value={deliveryAt} onChange={setDeliveryAt} />
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="editStatus">وضعیت</Label>
            <SearchableSelect
              id="editStatus"
              items={TICKET_STATUSES.map((value) => ({
                id: value,
                name: TICKET_STATUS_LABELS[value],
              }))}
              value={status}
              onChange={(value) => setStatus(value as RepairTicketStatus)}
            />
          </div>
        </div>

        <div className="flex flex-col gap-1.5">
          <Label>ایرادات</Label>
          <ChipMultiSelect
            items={catalog.data?.issues ?? []}
            selectedIds={issueIds}
            onToggle={(id) => toggle(issueIds, setIssueIds, id)}
            onAdd={() => toast('برای افزودن ایراد جدید از فرم پذیرش استفاده کنید')}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label>متعلقات</Label>
          <ChipMultiSelect
            items={catalog.data?.accessories ?? []}
            selectedIds={accessoryIds}
            onToggle={(id) => toggle(accessoryIds, setAccessoryIds, id)}
            onAdd={() => toast('برای افزودن متعلقات جدید از فرم پذیرش استفاده کنید')}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="editTechNotes">توضیحات تعمیرکار</Label>
          <Textarea
            id="editTechNotes"
            rows={2}
            value={technicianNotes}
            onChange={(event) => setTechnicianNotes(event.target.value)}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="editCustNotes">توضیحات برای مشتری</Label>
          <Textarea
            id="editCustNotes"
            rows={2}
            value={customerNotes}
            onChange={(event) => setCustomerNotes(event.target.value)}
          />
        </div>

        <Button onClick={handleSubmit} disabled={updateTicket.isPending}>
          {updateTicket.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ذخیره تغییرات
        </Button>
      </div>

      <PatternLockDialog
        open={isPatternOpen}
        onClose={() => setIsPatternOpen(false)}
        onSubmit={setDevicePassword}
      />
    </Dialog>
  );
}
