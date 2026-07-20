'use client';

import { useState } from 'react';
import { Loader2 } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { SearchableSelect } from '@/shared/components/ui/searchable-select';
import { useToast } from '@/shared/components/providers/toast-provider';
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

/** دکمه‌های اقدام مجاز + دیالوگ ورودی (تعمیرکار/علت) */
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
  const [reason, setReason] = useState('');

  const needsDialog = pending?.requiresTechnician || pending?.requiresReason;
  const technicians = useTechnicians(Boolean(pending?.requiresTechnician));

  const actions = getAvailableActions(ticket.status, assignedToId, currentUserId, permissions);
  if (actions.length === 0) {
    return (
      <p className="text-[12px] text-muted-foreground">
        اقدام قابل انجامی برای شما در این وضعیت وجود ندارد.
      </p>
    );
  }

  const run = (def: TicketActionDef, payload?: { technicianId?: string; reason?: string }) => {
    applyAction.mutate(
      { ticketId: ticket.id, action: def.action, ...payload },
      {
        onSuccess: () => {
          toast(`${def.label} انجام شد`);
          setPending(null);
          setTechnicianId('');
          setReason('');
          onDone?.();
        },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const openAction = (def: TicketActionDef) => {
    setTechnicianId('');
    setReason('');
    if (def.requiresTechnician || def.requiresReason) setPending(def);
    else run(def);
  };

  return (
    <>
      <div className="flex flex-wrap gap-2">
        {actions.map((def) => (
          <Button
            key={def.action}
            variant={def.tone === 'primary' ? 'default' : def.tone === 'destructive' ? 'destructive' : 'outline'}
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
        onClose={() => setPending(null)}
        title={pending?.label ?? ''}
      >
        <div className="flex flex-col gap-3.5">
          {pending?.requiresTechnician && (
            <div className="flex flex-col gap-1.5">
              <Label>تعمیرکار مقصد</Label>
              <SearchableSelect
                items={(technicians.data ?? []).map((tech) => ({ id: tech.id, name: tech.name }))}
                value={technicianId}
                onChange={setTechnicianId}
                placeholder="انتخاب تعمیرکار…"
                emptyText="تعمیرکاری تعریف نشده"
              />
            </div>
          )}

          {pending?.requiresReason && (
            <div className="flex flex-col gap-1.5">
              <Label htmlFor="actionReason">علت</Label>
              <Textarea
                id="actionReason"
                rows={2}
                value={reason}
                onChange={(event) => setReason(event.target.value)}
                placeholder="مثلاً: نیاز به تعویض ال سی دی — ارجاع به متخصص"
              />
            </div>
          )}

          <div className="flex gap-2">
            <Button
              disabled={applyAction.isPending}
              onClick={() => {
                if (!pending) return;
                if (pending.requiresTechnician && !technicianId) {
                  toast('تعمیرکار را انتخاب کنید', 'error');
                  return;
                }
                if (pending.requiresReason && !reason.trim()) {
                  toast('علت را وارد کنید', 'error');
                  return;
                }
                run(pending, { technicianId: technicianId || undefined, reason: reason.trim() || undefined });
              }}
            >
              {applyAction.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
              تایید
            </Button>
            <Button variant="outline" onClick={() => setPending(null)}>
              انصراف
            </Button>
          </div>
        </div>
      </Dialog>
    </>
  );
}
