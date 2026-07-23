'use client';

import { useRef, useState } from 'react';
import { Camera, Loader2, Trash2, User as UserIcon } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { ConfirmDialog } from '@/shared/components/ui/confirm-dialog';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useUploadAvatar, useRemoveAvatar } from '../hooks/use-profile';
import type { ProfileDto } from '../types/profile.types';

export function AvatarCard({ profile }: { profile: ProfileDto }) {
  const { toast } = useToast();
  const inputRef = useRef<HTMLInputElement>(null);
  const upload = useUploadAvatar();
  const remove = useRemoveAvatar();
  const [confirmRemove, setConfirmRemove] = useState(false);

  const handleFile = (file: File | undefined) => {
    if (!file) return;
    upload.mutate(file, {
      onSuccess: () => toast('تصویر پروفایل به‌روزرسانی شد'),
      onError: (error) => toast(error.message, 'error'),
    });
    if (inputRef.current) inputRef.current.value = '';
  };

  return (
    <div className="flex flex-col items-center gap-4 rounded-lg border border-border bg-card p-6">
      <div className="relative">
        <div className="flex h-28 w-28 items-center justify-center overflow-hidden rounded-full border-2 border-border bg-muted">
          {profile.avatarUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={profile.avatarUrl}
              alt={profile.name}
              className="h-full w-full object-cover"
            />
          ) : (
            <UserIcon className="h-12 w-12 text-muted-foreground" />
          )}
        </div>

        <button
          type="button"
          onClick={() => inputRef.current?.click()}
          disabled={upload.isPending}
          className="absolute bottom-0 left-0 flex h-9 w-9 items-center justify-center rounded-full border-2 border-card bg-primary text-primary-foreground disabled:opacity-60"
          aria-label="تغییر تصویر"
        >
          {upload.isPending ? (
            <Loader2 className="h-4 w-4 animate-spin" />
          ) : (
            <Camera className="h-4 w-4" />
          )}
        </button>
      </div>

      <input
        ref={inputRef}
        type="file"
        accept="image/jpeg,image/png,image/webp"
        className="hidden"
        onChange={(event) => handleFile(event.target.files?.[0])}
      />

      <div className="text-center">
        <div className="text-[15px] font-extrabold">{profile.name}</div>
        <div dir="ltr" className="text-[12.5px] text-muted-foreground">
          {profile.phone}
        </div>
        {profile.roles.length > 0 && (
          <div className="mt-2 flex flex-wrap justify-center gap-1.5">
            {profile.roles.map((role) => (
              <span
                key={role}
                className="rounded-full bg-accent px-2.5 py-1 text-[11px] font-bold text-accent-foreground"
              >
                {role}
              </span>
            ))}
          </div>
        )}
      </div>

      {profile.avatarUrl && (
        <Button
          variant="outline"
          className="h-9 w-auto px-4 text-[12px]"
          onClick={() => setConfirmRemove(true)}
        >
          <Trash2 className="h-3.5 w-3.5" />
          حذف تصویر
        </Button>
      )}

      <p className="text-center text-[11px] leading-5 text-muted-foreground">
        فرمت‌های مجاز: JPG، PNG، WebP — حداکثر ۲ مگابایت
      </p>

      <ConfirmDialog
        open={confirmRemove}
        title="حذف تصویر پروفایل"
        message="تصویر پروفایل شما حذف می‌شود."
        confirmLabel="حذف"
        isPending={remove.isPending}
        onClose={() => setConfirmRemove(false)}
        onConfirm={() =>
          remove.mutate(undefined, {
            onSuccess: () => {
              toast('تصویر حذف شد');
              setConfirmRemove(false);
            },
            onError: (error) => toast(error.message, 'error'),
          })
        }
      />
    </div>
  );
}
