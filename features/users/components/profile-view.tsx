'use client';

import { useEffect, useState } from 'react';
import { KeyRound, Loader2, Save } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useProfile, useUpdateProfile, useChangePassword } from '../hooks/use-profile';
import { AvatarCard } from './avatar-card';

export function ProfileView() {
  const { toast } = useToast();
  const profile = useProfile();
  const updateProfile = useUpdateProfile();
  const changePassword = useChangePassword();

  const [name, setName] = useState('');
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  useEffect(() => {
    if (profile.data) setName(profile.data.name);
  }, [profile.data]);

  if (profile.isLoading) {
    return (
      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <Skeleton className="h-80 w-full" />
        <Skeleton className="h-80 w-full lg:col-span-2" />
      </div>
    );
  }

  if (!profile.data) return null;

  const saveName = () => {
    if (name.trim().length < 2) {
      toast('نام باید حداقل ۲ کاراکتر باشد', 'error');
      return;
    }
    updateProfile.mutate(
      { name: name.trim() },
      {
        onSuccess: () => toast('اطلاعات ذخیره شد'),
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const savePassword = () => {
    if (!currentPassword || !newPassword || !confirmPassword) {
      toast('همه‌ی فیلدهای رمز را پر کنید', 'error');
      return;
    }
    if (newPassword !== confirmPassword) {
      toast('رمز جدید و تکرار آن یکسان نیستند', 'error');
      return;
    }

    changePassword.mutate(
      { currentPassword, newPassword, confirmPassword },
      {
        onSuccess: () => {
          toast('رمز عبور تغییر کرد؛ سایر دستگاه‌ها از حساب خارج شدند');
          setCurrentPassword('');
          setNewPassword('');
          setConfirmPassword('');
        },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  return (
    <div className="space-y-4">
      <h1 className="text-xl font-extrabold">پروفایل من</h1>

      <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
        <AvatarCard profile={profile.data} />

        <div className="space-y-4 lg:col-span-2">
          {/* اطلاعات پایه */}
          <div className="rounded-lg border border-border bg-card p-5">
            <h2 className="mb-4 text-sm font-extrabold">اطلاعات کاربری</h2>

            <div className="space-y-3">
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="profileName">نام و نام خانوادگی</Label>
                <Input
                  id="profileName"
                  value={name}
                  onChange={(event) => setName(event.target.value)}
                />
              </div>

              <div className="flex flex-col gap-1.5">
                <Label htmlFor="profilePhone">شماره همراه</Label>
                <Input
                  id="profilePhone"
                  dir="ltr"
                  className="text-right"
                  value={profile.data.phone}
                  disabled
                />
                <p className="text-[11px] text-muted-foreground">
                  تغییر شماره همراه فقط توسط مدیر سیستم امکان‌پذیر است
                </p>
              </div>

              <Button
                className="h-10 w-auto px-5 text-[13px]"
                disabled={updateProfile.isPending}
                onClick={saveName}
              >
                {updateProfile.isPending ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <Save className="h-4 w-4" />
                )}
                ذخیره تغییرات
              </Button>
            </div>
          </div>

          {/* تغییر رمز */}
          <div className="rounded-lg border border-border bg-card p-5">
            <h2 className="mb-1 text-sm font-extrabold">تغییر رمز عبور</h2>
            <p className="mb-4 text-[11.5px] text-muted-foreground">
              پس از تغییر رمز، از سایر دستگاه‌ها خارج می‌شوید.
            </p>

            <div className="space-y-3">
              <div className="flex flex-col gap-1.5">
                <Label htmlFor="currentPassword">رمز فعلی</Label>
                <Input
                  id="currentPassword"
                  type="password"
                  dir="ltr"
                  className="text-right"
                  value={currentPassword}
                  onChange={(event) => setCurrentPassword(event.target.value)}
                />
              </div>

              <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="newPassword">رمز جدید</Label>
                  <Input
                    id="newPassword"
                    type="password"
                    dir="ltr"
                    className="text-right"
                    value={newPassword}
                    onChange={(event) => setNewPassword(event.target.value)}
                  />
                </div>
                <div className="flex flex-col gap-1.5">
                  <Label htmlFor="confirmPassword">تکرار رمز جدید</Label>
                  <Input
                    id="confirmPassword"
                    type="password"
                    dir="ltr"
                    className="text-right"
                    value={confirmPassword}
                    onChange={(event) => setConfirmPassword(event.target.value)}
                  />
                </div>
              </div>

              <Button
                variant="outline"
                className="h-10 w-auto px-5 text-[13px]"
                disabled={changePassword.isPending}
                onClick={savePassword}
              >
                {changePassword.isPending ? (
                  <Loader2 className="h-4 w-4 animate-spin" />
                ) : (
                  <KeyRound className="h-4 w-4" />
                )}
                تغییر رمز عبور
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
