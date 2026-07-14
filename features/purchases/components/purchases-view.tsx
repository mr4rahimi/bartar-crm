'use client';

import { useState } from 'react';
import Link from 'next/link';
import { Loader2, ShoppingCart } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Dialog } from '@/shared/components/ui/dialog';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { StatusChip } from '@/shared/components/ui/status-chip';
import { Textarea } from '@/shared/components/ui/textarea';
import { Label } from '@/shared/components/ui/label';
import { useToast } from '@/shared/components/providers/toast-provider';
import { cn } from '@/shared/lib/cn';
import type { PartRequestDto } from '@/features/part-requests/types/part-request.types';
import { QUALITY_LABELS } from '@/features/part-requests/constants/state-machine.constants';
import {
  usePurchaseQueue,
  usePurchases,
  useQueueAction,
  useReturnPurchase,
} from '../hooks/use-purchases';
import { PurchaseFormDialog } from './purchase-form-dialog';
import type { PurchaseDto } from '../types/purchase.types';

type Tab = 'WAITING_PURCHASE' | 'PURCHASING' | 'HISTORY';

const TABS: { value: Tab; label: string }[] = [
  { value: 'WAITING_PURCHASE', label: 'در صف خرید' },
  { value: 'PURCHASING', label: 'در حال خرید' },
  { value: 'HISTORY', label: 'خریدهای اخیر' },
];

export function PurchasesView() {
  const [tab, setTab] = useState<Tab>('WAITING_PURCHASE');
  const [page, setPage] = useState(1);
  const [purchaseTarget, setPurchaseTarget] = useState<PartRequestDto | null>(null);
  const [notFoundTarget, setNotFoundTarget] = useState<PartRequestDto | null>(null);
  const [returnTarget, setReturnTarget] = useState<PurchaseDto | null>(null);
  const [reason, setReason] = useState('');

  const { toast } = useToast();
  const queueAction = useQueueAction();
  const returnPurchase = useReturnPurchase();

  const isHistory = tab === 'HISTORY';
  const queue = usePurchaseQueue(isHistory ? 'WAITING_PURCHASE' : tab, isHistory ? 1 : page);
  const purchases = usePurchases(isHistory ? page : 1);

  const handleStartPurchase = (request: PartRequestDto) => {
    queueAction.mutate(
      { requestId: request.id, action: 'START_PURCHASE' },
      {
        onSuccess: () => toast('شروع خرید ثبت شد'),
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const handleNotFound = () => {
    if (!notFoundTarget) return;
    queueAction.mutate(
      {
        requestId: notFoundTarget.id,
        action: 'MARK_NOT_FOUND',
        description: reason.trim() || undefined,
      },
      {
        onSuccess: () => { toast('عدم موجودی ثبت شد'); setNotFoundTarget(null); setReason(''); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const handleReturn = () => {
    if (!returnTarget || !reason.trim()) {
      toast('علت مرجوعی را وارد کنید', 'error');
      return;
    }
    returnPurchase.mutate(
      { purchaseId: returnTarget.id, reason: reason.trim() },
      {
        onSuccess: () => { toast('مرجوعی ثبت شد'); setReturnTarget(null); setReason(''); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const queueItems = queue.data?.items ?? [];
  const isLoading = isHistory ? purchases.isLoading : queue.isLoading;

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-extrabold">خرید قطعات</h1>

      <div className="flex gap-2">
        {TABS.map((item) => (
          <button
            key={item.value}
            type="button"
            onClick={() => { setTab(item.value); setPage(1); }}
            className={cn(
              'rounded-full border px-3.5 py-1.5 text-xs font-semibold',
              tab === item.value
                ? 'border-primary bg-accent text-accent-foreground'
                : 'border-border bg-card text-muted-foreground',
            )}
          >
            {item.label}
          </button>
        ))}
      </div>

      {isLoading && (
        <div className="space-y-2">
          {[1, 2, 3].map((key) => <Skeleton key={key} className="h-28 w-full" />)}
        </div>
      )}

      {!isHistory && !queue.isLoading && queueItems.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12">
          <ShoppingCart className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">موردی در این صف نیست</p>
        </div>
      )}

      {!isHistory &&
        queueItems.map((request) => (
          <div key={request.id} className="rounded-lg border border-border bg-card p-3.5">
            <Link href={`/part-requests/${request.id}`} className="block">
              <div className="flex items-center justify-between gap-2">
                <div className="text-[13.5px] font-extrabold">{request.partName}</div>
                <StatusChip status={request.status} />
              </div>
              <div className="mt-1.5 text-[12.5px] text-muted-foreground">
                پذیرش #{request.receptionNumber} — {QUALITY_LABELS[request.quality]} —{' '}
                {request.quantity} عدد
                {(request.brand || request.model) &&
                  ` — ${[request.brand, request.model].filter(Boolean).join(' ')}`}
              </div>
              {request.announcedPrice !== null && (
                <div className="mt-1 text-[12.5px] font-bold">
                  اعلامی: {request.announcedPrice.toLocaleString('fa-IR')} تومان
                </div>
              )}
            </Link>

            <div className="mt-3 flex flex-wrap gap-2">
              {request.status === 'WAITING_PURCHASE' && (
                <Button
                  variant="outline"
                  className="h-10 w-auto flex-1 px-3 text-[12.5px]"
                  disabled={queueAction.isPending}
                  onClick={() => handleStartPurchase(request)}
                >
                  شروع خرید
                </Button>
              )}
              <Button
                className="h-10 w-auto flex-1 px-3 text-[12.5px]"
                onClick={() => setPurchaseTarget(request)}
              >
                ثبت خرید
              </Button>
              <Button
                variant="destructive"
                className="h-10 w-auto flex-1 px-3 text-[12.5px]"
                onClick={() => { setNotFoundTarget(request); setReason(''); }}
              >
                عدم موجودی
              </Button>
            </div>
          </div>
        ))}

      {isHistory &&
        purchases.data?.items.map((purchase) => (
          <div key={purchase.id} className="rounded-lg border border-border bg-card p-3.5">
            <div className="flex items-center justify-between gap-2">
              <div className="text-[13.5px] font-extrabold">{purchase.partName}</div>
              <span className="text-[13px] font-extrabold">
                {purchase.price.toLocaleString('fa-IR')} تومان
              </span>
            </div>
            <div className="mt-1.5 text-[12.5px] text-muted-foreground">
              پذیرش #{purchase.receptionNumber} — فروشنده: {purchase.vendor.name} — خریدار:{' '}
              {purchase.buyerName}
            </div>
            <div className="mt-1 text-[11.5px] text-muted-foreground">
              {new Date(purchase.purchasedAt).toLocaleString('fa-IR')}
            </div>
            <div className="mt-3">
              {purchase.isReturned ? (
                <span className="text-[12px] font-bold text-destructive">
                  مرجوع شد — {purchase.returnReason}
                </span>
              ) : (
                <Button
                  variant="outline"
                  className="h-9 w-auto px-4 text-xs"
                  onClick={() => { setReturnTarget(purchase); setReason(''); }}
                >
                  ثبت مرجوعی
                </Button>
              )}
            </div>
          </div>
        ))}

      <PurchaseFormDialog request={purchaseTarget} onClose={() => setPurchaseTarget(null)} />

      <Dialog
        open={notFoundTarget !== null}
        onClose={() => setNotFoundTarget(null)}
        title="ثبت عدم موجودی؟"
      >
        <div className="flex flex-col gap-3.5">
          <p className="text-sm text-muted-foreground">
            «{notFoundTarget?.partName}» به وضعیت عدم موجودی می‌رود (قابل بازگشت به صف است).
          </p>
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="nfReason">توضیح (اختیاری)</Label>
            <Textarea id="nfReason" rows={2} value={reason} onChange={(event) => setReason(event.target.value)} />
          </div>
          <div className="flex gap-2">
            <Button variant="destructive" onClick={handleNotFound} disabled={queueAction.isPending}>
              {queueAction.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
              ثبت
            </Button>
            <Button variant="outline" onClick={() => setNotFoundTarget(null)}>انصراف</Button>
          </div>
        </div>
      </Dialog>

      <Dialog open={returnTarget !== null} onClose={() => setReturnTarget(null)} title="ثبت مرجوعی">
        <div className="flex flex-col gap-3.5">
          <div className="flex flex-col gap-1.5">
            <Label htmlFor="returnReason">علت مرجوعی</Label>
            <Textarea id="returnReason" rows={2} value={reason} onChange={(event) => setReason(event.target.value)} />
          </div>
          <div className="flex gap-2">
            <Button variant="destructive" onClick={handleReturn} disabled={returnPurchase.isPending}>
              {returnPurchase.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
              ثبت مرجوعی
            </Button>
            <Button variant="outline" onClick={() => setReturnTarget(null)}>انصراف</Button>
          </div>
        </div>
      </Dialog>
    </div>
  );
}
