'use client';

import { useEffect, useState } from 'react';
import { Loader2 } from 'lucide-react';
import { Dialog } from './dialog';
import { Button } from './button';
import { Input } from './input';
import { Label } from './label';

type PromptDialogProps = {
  open: boolean;
  title: string;
  label: string;
  placeholder?: string;
  confirmText?: string;
  isPending?: boolean;
  onSubmit: (value: string) => void;
  onClose: () => void;
};

// جایگزین شیک window.prompt — یک فیلد متنی با تایید
export function PromptDialog({
  open,
  title,
  label,
  placeholder,
  confirmText = 'افزودن',
  isPending = false,
  onSubmit,
  onClose,
}: PromptDialogProps) {
  const [value, setValue] = useState('');

  useEffect(() => {
    if (open) setValue('');
  }, [open]);

  const handleSubmit = () => {
    if (value.trim()) onSubmit(value.trim());
  };

  return (
    <Dialog open={open} onClose={onClose} title={title}>
      <div className="flex flex-col gap-3.5">
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="promptValue">{label}</Label>
          <Input
            id="promptValue"
            value={value}
            placeholder={placeholder}
            onChange={(event) => setValue(event.target.value)}
            onKeyDown={(event) => event.key === 'Enter' && handleSubmit()}
            autoFocus
          />
        </div>
        <div className="flex gap-2">
          <Button onClick={handleSubmit} disabled={isPending || !value.trim()}>
            {isPending && <Loader2 className="h-4 w-4 animate-spin" />}
            {confirmText}
          </Button>
          <Button variant="outline" onClick={onClose}>
            انصراف
          </Button>
        </div>
      </div>
    </Dialog>
  );
}
