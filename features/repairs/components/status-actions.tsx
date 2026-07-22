'use client';

import { useState } from 'react';
import { Loader2 } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { Switch } from '@/shared/components/ui/switch';
import { SearchableSelect } from '@/shared/components/ui/searchable-select';
import { useToast } from '@/shared/components/providers/toast-provider';
import { cn } from '@/shared/lib/cn';
import { getAvailableActions } from '../utils/available-actions';
import { useTechnicians, useApplyTicketAction } from '../hooks/use-workflow';
import type { TicketActionDef } from '../constants/workflow.constants';
import type { TicketDto } from '../types/ticket.types';

type StatusActionsProps = {
  ticket: TicketDto;
  assignedToId: string | null;
  currentUserId: string;
  permissions: string[];
  onDone?: () => void;
};

export function StatusActions({
  ticket,
  assignedToId,
  currentUserId,
  permissions,
  onDone,
}: StatusActionsProps) {
  const { toast } = useToast();
  const applyAction = useApplyTicketAction();
  const [pending, setPending] = useState<TicketActionDef | null>(null);
  const [technicianId, setTechnicianId] = useState('');
  const [selfCheck, setSelfCheck] = useState(true);
  const [reason, setReason] = useState('');
  const [qualityNotes, setQualityNotes] = useState('');
  const [notifyCustomer, setNotifyCustomer] = useState(true);

  const needsDialog =
    pending?.requiresTechnician ||
    pending?.requiresReason ||
    pending?.requiresQualityNotes ||
    pending?.asksCustomerSms;

  const technicians = useTechnicians(Boolean(pending?.requiresTechnician));

  const actions = getAvailableActions(ticket.status, assignedToId, currentUserId, permissions);
  if (actions.length === 0) {
    return (
      <p className="text-[12px] text-muted-foreground">
        اقدام قابل انجامی برای شما در این وضعیت وجود ندارد.
      </p>
    );
  }

  const reset = () => {
    setPending(null);
    setTechnicianId('');
    setSelfCheck(true);
    setReason('');
    setQualityNotes('');
    setNotifyCustomer(true);
  };

  const run = (
    def: TicketActionDef,
    payload?: {
      technicianId?: string;
      reason?: string;
      qualityNotes?: string;
      notifyCustomer?: boolean;
    },
  ) => {
    applyAction.mutate(
      { ticketId: ticket.id, action: def.action, ...payload },
      {
        onSuccess: () => {
          toast(`${def.label} انجام شد`);
          reset();
          onDone?.();
        },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const openAction = (def: TicketActionDef) => {
    setTechnicianId('');
    setSelfCheck(true);
    setReason('');
    setQualityNotes('');
    setNotifyCustomer(true);
    if (def.requiresTechnician || def.requiresReason || def.requiresQualityNotes || def.asksCustomerSms) {
      setPending(def);
    } else {
      run(def);
    }
  };

  const submit = () => {
    if (!pending) return;

    // انتخاب تعمیرکار: اگر اختیاری است و «خودم» انتخاب شده، خالی می‌رود
    if (pending.requiresTechnician) {
      const needsPick = pending.technicianOptional ? !selfCheck : true;
      if (needsPick && !technicianId) {
        toast('تعمیرکار را انتخاب کنید', 'error');
        return;
      }
    }
    if (pending.requiresReason && !reason.trim()) {
      toast('علت را وارد کنید', 'error');
      return;
    }
    if (pending.requiresQualityNotes && !qualityNotes.trim()) {
      toast('موارد کنترل‌شده را بنویسید', 'error');
      return;
    }

    const sendTechnician =
      pending.requiresTechnician && (!pending.technicianOptional || !selfCheck)
        ? technicianId
        : undefined;

    run(pending, {
      technicianId: sendTechnician || undefined,
      reason: reason.trim() || undefined,
      qualityNotes: qualityNotes.trim() || undefined,
      ...(pending.asksCustomerSms && { notifyCustomer }),
    });
  };

  return (
    <>
      <div className="flex flex-wrap gap-2">
        {actions.map((def) => (
          <Button
            key={def.action}
            variant={
              def.tone === 'primary' ? 'default' : def.tone === 'destructive' ? 'destructive' : 'outline'
            }
            className="h-10 w-auto flex-1 px-4 text-[13px] sm:flex-none"
            disabled={applyAction.isPending}
            onClick={() => openAction(def)}
          >
            {def.label}
          </Button>
        ))}
      </div>

      <Dialog
        open={pending !== null && Boolean(needsDialog)}
        onClose={reset}
        title={pending?.label ?? ''}
      >
        <div className="flex flex-col gap-3.5">
          {pending?.requiresTechnician && (
            <div className="flex flex-col gap-2">
              {pending.technicianOptional && (
                <div className="flex gap-2">
                  {[
                    { value: true, label: 'کنترل کیفیت توسط خودم' },
                    { value: false, label: 'تعمیرکار دیگر' },
                  ].map((option) => (
                    <button
                      key={String(option.value)}
                      type="button"
                      onClick={() => setSelfCheck(option.value)}
                      className={cn(
                        'flex-1 rounded-md border px-3 py-2.5 text-[12.5px] font-bold',
                        selfCheck === option.value
                          ? 'border-primary bg-accent text-accent-foreground'
                          : 'border-border bg-card text-muted-foreground',
                      )}
                    >
                      {option.label}
                    </button>
                  ))}
                </div>
              )}

              {(!pending.technicianOptional || !selfCheck) && (
                <div className="flex flex-col gap-1.5">
                  <Label>تعمیرکار مقصد</Label>
                  <SearchableSelect
                    items={(technicians.data ?? [])
                      .filter((tech) => tech.id !== currentUserId || !pending.technicianOptional)
                      .map((tech) => ({ id: tech.id, name: tech.name }))}
                    value={technicianId}
                    onChange={setTechnicianId}
                    placeholder="انتخاب تعمیرکار…"
                    emptyText="تعمیرکاری تعریف نشده"
                  />
                </div>
              )}

              {pending.technicianOptional && selfCheck && (
                <p className="rounded-md bg-muted px-3 py-2 text-[11.5px] leading-5 text-muted-foreground">
                  دستگاه نزد شما می‌ماند و باید موارد کنترل‌شده را ثبت کنید تا به پذیرش ارجاع شود.
                </p>
              )}
            </div>
          )}

          {pending?.requiresQualityNotes && (
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="qualityNotes">موارد کنترل‌شده</Label>
              <Textarea
                id="qualityNotes"
                rows={3}
                value={qualityNotes}
                onChange={(event) => setQualityNotes(event.target.value)}
                placeholder="مثلاً: تست تماس، دوربین، شارژ، لمس صفحه و آنتن‌دهی انجام شد"
              />
            </div>
          )}

          {pending?.requiresReason && (
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="actionReason">
                {pending.action === 'MARK_UNREPAIRABLE' ? 'دلیل عدم تعمیر' : 'علت'}
              </Label>
              <Textarea
                id="actionReason"
                rows={2}
                value={reason}
                onChange={(event) => setReason(event.target.value)}
                placeholder={
                  pending.action === 'MARK_UNREPAIRABLE'
                    ? 'مثلاً: برد اصلی آب‌خوردگی شدید دارد و قابل ترمیم نیست'
                    : 'دلیل را بنویسید…'
                }
              />
            </div>
          )}

          {pending?.asksCustomerSms && (
            <div className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-3">
              <div>
                <Label htmlFor="notifyCustomer" className="text-[12.5px]">
                  اطلاع‌رسانی پیامکی به مشتری
                </Label>
                <p className="mt-0.5 text-[11px] text-muted-foreground">
                  پیامک آماده‌بودن دستگاه برای {ticket.customer.name} ارسال شود
                </p>
              </div>
              <Switch
                id="notifyCustomer"
                checked={notifyCustomer}
                onCheckedChange={setNotifyCustomer}
              />
            </div>
          )}

          <div className="flex gap-2">
            <Button disabled={applyAction.isPending} onClick={submit}>
              {applyAction.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
              تایید
            </Button>
            <Button variant="outline" onClick={reset}>
              انصراف
            </Button>
          </div>
        </div>
      </Dialog>
    </>
  );
}
