'use client';

import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useCreateTicket } from '../hooks/use-ticket-mutations';
import { useCatalog } from '../hooks/use-catalog';
import { CustomerPicker, type CustomerSelection } from './customer-picker';

type TicketFormDialogProps = {
  open: boolean;
  onClose: () => void;
};

export function TicketFormDialog({ open, onClose }: TicketFormDialogProps) {
  const { toast } = useToast();
  const createTicket = useCreateTicket();
  const catalog = useCatalog();

  const [customer, setCustomer] = useState<CustomerSelection>(null);
  const [brandName, setBrandName] = useState('');
  const [modelName, setModelName] = useState('');
  const [serial, setSerial] = useState('');
  const [issueDescription, setIssueDescription] = useState('');

  useEffect(() => {
    if (!open) return;
    setCustomer(null);
    setBrandName('');
    setModelName('');
    setSerial('');
    setIssueDescription('');
  }, [open]);

  const modelOptions =
    catalog.data?.find((brand) => brand.name === brandName.trim())?.models ?? [];

  const handleSubmit = () => {
    if (!customer) {
      toast('مشتری را انتخاب کنید یا بسازید', 'error');
      return;
    }

    createTicket.mutate(
      {
        customerId: customer.kind === 'existing' ? customer.customer.id : undefined,
        newCustomer:
          customer.kind === 'new' ? { name: customer.name, phone: customer.phone } : undefined,
        brandName: brandName.trim(),
        modelName: modelName.trim(),
        serial: serial.trim() || undefined,
        issueDescription: issueDescription.trim() || undefined,
      },
      {
        onSuccess: (ticket) => {
          toast(`تیکت #${ticket.ticketNumber} ثبت شد`);
          onClose();
        },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  return (
    <Dialog open={open} onClose={onClose} title="پذیرش جدید">
      <div className="flex flex-col gap-3.5">
        <CustomerPicker value={customer} onChange={setCustomer} />

        <div className="grid grid-cols-2 gap-2.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="brand">برند</Label>
            <Input
              id="brand"
              list="brand-options"
              placeholder="مثلاً: Samsung"
              value={brandName}
              onChange={(event) => setBrandName(event.target.value)}
            />
            <datalist id="brand-options">
              {catalog.data?.map((brand) => <option key={brand.id} value={brand.name} />)}
            </datalist>
          </div>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="model">مدل</Label>
            <Input
              id="model"
              list="model-options"
              placeholder="مثلاً: Galaxy A52"
              value={modelName}
              onChange={(event) => setModelName(event.target.value)}
            />
            <datalist id="model-options">
              {modelOptions.map((model) => <option key={model.id} value={model.name} />)}
            </datalist>
          </div>
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="serial">سریال (اختیاری)</Label>
          <Input
            id="serial"
            dir="ltr"
            className="text-right"
            value={serial}
            onChange={(event) => setSerial(event.target.value)}
          />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="issue">شرح ایراد</Label>
          <Textarea
            id="issue"
            rows={3}
            placeholder="مثلاً: روشن نمی‌شود"
            value={issueDescription}
            onChange={(event) => setIssueDescription(event.target.value)}
          />
        </div>

        <Button onClick={handleSubmit} disabled={createTicket.isPending}>
          {createTicket.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          ثبت پذیرش
        </Button>
      </div>
    </Dialog>
  );
}
