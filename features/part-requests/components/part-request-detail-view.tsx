'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { ArrowRight, Loader2, Pencil } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { Dialog } from '@/shared/components/ui/dialog';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { StatusChip } from '@/shared/components/ui/status-chip';
import { PriceInput } from '@/shared/components/ui/price-input';
import { PART_REQUEST_STATUS_LABELS } from '@/shared/constants/part-request-status';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { cn } from '@/shared/lib/cn';
import { usePartRequest } from '../hooks/use-part-requests';
import { useApplyPartRequestAction } from '../hooks/use-part-request-mutations';
import { usePriceCheck } from '../hooks/use-price-check';
import { PriceWarning } from './price-warning';
import { PartRequestEditDialog } from './part-request-edit-dialog';
import { RequestLogList } from './request-log-list';
import { ACTION_DEFS, QUALITY_LABELS, type ActionDef } from '../constants/state-machine.constants';

type DetailViewProps = { requestId: string; permissions: string[] };

export function PartRequestDetailView({ requestId, permissions }: DetailViewProps) {
  const router = useRouter();
  const { toast } = useToast();
  const query = usePartRequest(requestId);
  const applyAction = useApplyPartRequestAction();

  const [pendingAction, setPendingAction] = useState<ActionDef | null>(null);
  const [isEditOpen, setIsEditOpen] = useState(false);
  const [price, setPrice] = useState('');
  const [description, setDescription] = useState('');

  const debouncedPrice = useDebouncedValue(price, 500);
  const request = query.data;

  const priceCheck = usePriceCheck({
    modelId: request?.modelId ?? null,
    partId: request?.partId ?? '',
    quality: request?.quality ?? 'ORIGINAL',
    price: pendingAction?.requiresPrice ? debouncedPrice : '',
  });

  if (query.isLoading) return <Skeleton className="h-96 w-full" />;
  if (!request) return null;

  const canEdit = permissions.includes('EDIT_PART_REQUEST');

  const availableActions = ACTION_DEFS.filter(
    (def) => def.from.includes(request.status) && permissions.includes(def.permission),
  );

  const openAction = (def: ActionDef) => {
    setPrice('');
    setDescription('');
    if (def.requiresPrice || def.requiresConfirm) {
      setPendingAction(def);
    } else {
      runAction(def);
    }
  };

  const runAction = (def: ActionDef) => {
    applyAction.mutate(
      {
        requestId,
        action: def.action,
        price: price.trim() || undefined,
        description: description.trim() || undefined,
      },
      {
        onSuccess: () => { toast(`${def.label} انجام شد`); setPendingAction(null); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const fields = [
    { label: 'شماره پذیرش', value: `#${request.receptionNumber}` },
    { label: 'کیفیت', value: QUALITY_LABELS[request.quality] },
    { label: 'تعداد', value: `${request.quantity} عدد` },
    { label: 'برند / مدل', value: [request.brand, request.model].filter(Boolean).join(' ') || '—' },
    {
      label: 'قیمت اعلامی',
      value: request.announcedPrice !== null
        ? `${request.announcedPrice.toLocaleString('fa-IR')} تومان`
        : '—',
    },
    {
      label: 'بیعانه',
      value: request.depositAmount > 0
        ? `${request.depositAmount.toLocaleString('fa-IR')} تومان`
        : '—',
    },
    { label: 'ثبت‌کننده', value: request.createdByName },
    { label: 'نوع', value: request.isTest ? 'تستی' : 'عادی' },
  ];

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <button
          type="button"
          onClick={() => router.push('/part-requests')}
          className="rounded-md p-1.5 text-muted-foreground hover:bg-muted"
          aria-label="بازگشت"
        >
          <ArrowRight className="h-5 w-5" />
        </button>
        <h1 className="flex-1 text-lg font-extrabold">{request.partName}</h1>
        {canEdit && (
          <button
            type="button"
            onClick={() => setIsEditOpen(true)}
            className="rounded-md border border-border p-1.5 text-muted-foreground hover:bg-muted"
            aria-label="ویرایش"
          >
            <Pencil className="h-4 w-4" />
          </button>
        )}
        <StatusChip status={request.status} />
      </div>

      <div className="grid grid-cols-2 gap-x-4 gap-y-3 rounded-lg border border-border bg-card p-4">
        {fields.map((field) => (
          <div key={field.label}>
            <div className="text-[11px] font-bold text-muted-foreground">{field.label}</div>
            <div className="mt-0.5 text-[13px] font-semibold">{field.value}</div>
          </div>
        ))}
        {request.description && (
          <div className="col-span-2">
            <div className="text-[11px] font-bold text-muted-foreground">توضیح</div>
            <div className="mt-0.5 text-[13px]">{request.description}</div>
          </div>
        )}
      </div>

      {availableActions.length > 0 && (
        <div className="flex flex-wrap gap-2">
          {availableActions.map((def) => (
            <Button
              key={def.action}
              variant={def.tone === 'primary' ? 'default' : def.tone}
              className="h-11 w-auto flex-1 px-4 text-[13px] sm:flex-none"
              disabled={applyAction.isPending}
              onClick={() => openAction(def)}
            >
              {def.label}
            </Button>
          ))}
        </div>
      )}

      <div className="rounded-lg border border-border bg-card p-4">
        <h2 className="mb-3 text-sm font-extrabold">تاریخچه وضعیت</h2>
        <div className="space-y-0">
          {request.history.map((entry, index) => (
            <div key={entry.id} className="relative flex gap-3 pb-4 last:pb-0">
              <div className="flex flex-col items-center">
                <span className={cn('mt-1 h-2.5 w-2.5 rounded-full', index === 0 ? 'bg-primary' : 'bg-muted-foreground/40')} />
                {index < request.history.length - 1 && <span className="w-px flex-1 bg-border" />}
              </div>
              <div className="pb-1">
                <div className="text-[13px] font-bold">
                  {PART_REQUEST_STATUS_LABELS[entry.newStatus]}
                </div>
                <div className="text-[11.5px] text-muted-foreground">
                  {entry.changedByName} — {new Date(entry.createdAt).toLocaleString('fa-IR')}
                </div>
                {entry.description && (
                  <div className="mt-0.5 text-[12px] text-muted-foreground">{entry.description}</div>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>

      <RequestLogList requestId={requestId} enabled={canEdit} />

      <Dialog
        open={pendingAction !== null}
        onClose={() => setPendingAction(null)}
        title={pendingAction?.label ?? ''}
      >
        <div className="flex flex-col gap-3.5">
          {pendingAction?.requiresPrice && (
            <>
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="actionPrice">قیمت اعلامی به مشتری (تومان)</Label>
                <PriceInput
                  id="actionPrice"
                  placeholder="مثلاً: ۲٬۵۰۰٬۰۰۰"
                  value={price}
                  onChange={setPrice}
                />
              </div>
              <PriceWarning check={priceCheck.data} />
            </>
          )}
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="actionDescription">توضیح (اختیاری)</Label>
            <Textarea
              id="actionDescription"
              rows={2}
              value={description}
              onChange={(event) => setDescription(event.target.value)}
            />
          </div>
          <div className="flex gap-2">
            <Button
              variant={pendingAction?.tone === 'destructive' ? 'destructive' : 'default'}
              disabled={applyAction.isPending}
              onClick={() => {
                if (pendingAction?.requiresPrice && !price.trim()) {
                  toast('قیمت اعلامی را وارد کنید', 'error');
                  return;
                }
                if (pendingAction) runAction(pendingAction);
              }}
            >
              {applyAction.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
              تایید
            </Button>
            <Button variant="outline" onClick={() => setPendingAction(null)}>
              انصراف
            </Button>
          </div>
        </div>
      </Dialog>

      {canEdit && (
        <PartRequestEditDialog
          open={isEditOpen}
          request={request}
          onClose={() => setIsEditOpen(false)}
        />
      )}
    </div>
  );
}
