'use client';

import { useRouter } from 'next/navigation';
import { User as UserIcon } from 'lucide-react';
import { useProfile } from '../hooks/use-profile';

/** آواتار کوچک هدر — کلیک: صفحه‌ی پروفایل */
export function HeaderAvatar() {
  const router = useRouter();
  const profile = useProfile();

  return (
    <button
      type="button"
      onClick={() => router.push('/profile')}
      title={profile.data?.name ?? 'پروفایل من'}
      aria-label="پروفایل من"
      className="flex h-9 w-9 items-center justify-center overflow-hidden rounded-full border border-border bg-muted transition-colors hover:border-primary"
    >
      {profile.data?.avatarUrl ? (
        // eslint-disable-next-line @next/next/no-img-element
        <img
          src={profile.data.avatarUrl}
          alt=""
          className="h-full w-full object-cover"
        />
      ) : (
        <UserIcon className="h-4.5 w-4.5 text-muted-foreground" />
      )}
    </button>
  );
}
