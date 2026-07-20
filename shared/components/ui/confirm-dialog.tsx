'use client';

import { Loader2 } from 'lucide-react';
import { Dialog } from './dialog';
import { Button } from './button';

type ConfirmDialogProps = {
  open: boolean;
  title: string;
  message: string;
  confirmLabel?: string;
  tone?: 'default' | 'destructive';
  isPending?: boolean;
  onConfirm: () => void;
  onClose: () => void;
};

export function ConfirmDialog({
  open,
  title,
  message,
  confirmLabel = 'تایید',
  tone = 'destructive',
  isPending = false,
  onConfirm,
  onClose,
}: ConfirmDialogProps) {
  if (!open) return null;

  return (
    <Dialog open onClose={onClose} title={title}>
      <div className="flex flex-col gap-4">
        <p className="text-[13px] leading-6 text-muted-foreground">{message}</p>
        <div className="flex gap-2">
          <Button variant={tone === 'destructive' ? 'destructive' : 'default'} disabled={isPending} onClick={onConfirm}>
            {isPending && <Loader2 className="h-4 w-4 animate-spin" />}
            {confirmLabel}
          </Button>
          <Button variant="outline" onClick={onClose}>
            انصراف
          </Button>
        </div>
      </div>
    </Dialog>
  );
}
