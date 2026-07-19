'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Loader2 } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Switch } from '@/shared/components/ui/switch';
import { useToast } from '@/shared/components/providers/toast-provider';
import {
  createUserFormSchema,
  editUserFormSchema,
  type UserFormValues,
} from '../validators/user-form.schema';
import { useUserMutations } from '../hooks/use-user-mutations';
import { useRoleOptions } from '../hooks/use-role-options';
import type { UserDto } from '../types/user.types';

type UserFormDialogProps = {
  open: boolean;
  user: UserDto | null;
  onClose: () => void;
};

export function UserFormDialog({ open, user, onClose }: UserFormDialogProps) {
  const isEdit = user !== null;
  const { toast } = useToast();
  const roleOptions = useRoleOptions();
  const { createUser, updateUser } = useUserMutations();
  const mutation = isEdit ? updateUser : createUser;

  const {
    register,
    handleSubmit,
    reset,
    watch,
    setValue,
    formState: { errors },
  } = useForm<UserFormValues>({
    resolver: zodResolver(isEdit ? editUserFormSchema : createUserFormSchema),
  });

  useEffect(() => {
    if (!open) return;
    reset({
      name: user?.name ?? '',
      phone: user?.phone ?? '',
      email: user?.email ?? '',
      password: '',
      isActive: user?.isActive ?? true,
      smsEnabled: user?.smsEnabled ?? true,
      roleIds: user?.roles.map((role) => role.id) ?? [],
    });
  }, [open, user, reset]);

  const isActive = watch('isActive');
  const smsEnabled = watch('smsEnabled');
  const selectedRoleIds = watch('roleIds') ?? [];

  const toggleRole = (roleId: string) => {
    const next = selectedRoleIds.includes(roleId)
      ? selectedRoleIds.filter((id) => id !== roleId)
      : [...selectedRoleIds, roleId];
    setValue('roleIds', next, { shouldValidate: true });
  };

  const onSubmit = (values: UserFormValues) => {
    const payload = {
      name: values.name,
      phone: values.phone,
      email: values.email === '' ? undefined : values.email,
      password: values.password === '' ? undefined : values.password,
      isActive: values.isActive,
      smsEnabled: values.smsEnabled,
      roleIds: values.roleIds,
    };

    if (isEdit) {
      updateUser.mutate(
        { userId: user.id, input: payload },
        {
          onSuccess: () => { toast('کاربر ویرایش شد'); onClose(); },
          onError: (error) => toast(error.message, 'error'),
        },
      );
    } else {
      createUser.mutate(
        { ...payload, password: values.password },
        {
          onSuccess: () => { toast('کاربر ساخته شد'); onClose(); },
          onError: (error) => toast(error.message, 'error'),
        },
      );
    }
  };

  return (
    <Dialog open={open} onClose={onClose} title={isEdit ? 'ویرایش کاربر' : 'کاربر جدید'}>
      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-3.5" noValidate>
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="name">نام و نام خانوادگی</Label>
          <Input id="name" {...register('name')} />
          {errors.name && <p className="text-xs text-destructive">{errors.name.message}</p>}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="phone">شماره موبایل</Label>
          <Input id="phone" dir="ltr" className="text-right" {...register('phone')} />
          {errors.phone && <p className="text-xs text-destructive">{errors.phone.message}</p>}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="email">ایمیل (اختیاری)</Label>
          <Input id="email" dir="ltr" className="text-right" placeholder="example@mail.com" {...register('email')} />
          {errors.email && <p className="text-xs text-destructive">{errors.email.message}</p>}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="password">رمز عبور</Label>
          <Input
            id="password"
            type="password"
            placeholder={isEdit ? 'برای تغییر وارد کنید' : ''}
            {...register('password')}
          />
          {errors.password && <p className="text-xs text-destructive">{errors.password.message}</p>}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label>نقش‌ها</Label>
          <div className="flex flex-wrap gap-2">
            {roleOptions.data?.map((role) => {
              const isSelected = selectedRoleIds.includes(role.id);
              return (
                <button
                  key={role.id}
                  type="button"
                  onClick={() => toggleRole(role.id)}
                  className={
                    isSelected
                      ? 'rounded-full border border-primary bg-accent px-3.5 py-1.5 text-xs font-semibold text-accent-foreground'
                      : 'rounded-full border border-border bg-card px-3.5 py-1.5 text-xs font-semibold text-muted-foreground'
                  }
                >
                  {role.name}
                </button>
              );
            })}
          </div>
          {errors.roleIds && <p className="text-xs text-destructive">{errors.roleIds.message}</p>}
        </div>

        <div className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-3">
          <Label htmlFor="isActive">حساب فعال</Label>
          <Switch
            id="isActive"
            checked={isActive ?? true}
            onCheckedChange={(checked) => setValue('isActive', checked)}
          />
        </div>

        <div className="flex items-center justify-between rounded-md border border-border bg-background px-3.5 py-3">
          <Label htmlFor="smsEnabled">دریافت پیامک اطلاع‌رسانی</Label>
          <Switch
            id="smsEnabled"
            checked={smsEnabled ?? true}
            onCheckedChange={(checked) => setValue('smsEnabled', checked)}
          />
        </div>

        <Button type="submit" disabled={mutation.isPending}>
          {mutation.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          {isEdit ? 'ذخیره تغییرات' : 'ساخت کاربر'}
        </Button>
      </form>
    </Dialog>
  );
}
