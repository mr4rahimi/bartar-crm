'use client';

import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { Loader2 } from 'lucide-react';
import { Dialog } from '@/shared/components/ui/dialog';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Label } from '@/shared/components/ui/label';
import { Textarea } from '@/shared/components/ui/textarea';
import { useToast } from '@/shared/components/providers/toast-provider';
import { createRoleSchema, type CreateRoleInput } from '../validators/role.schema';
import { useRoleMutations } from '../hooks/use-role-mutations';
import { usePermissions } from '../hooks/use-permissions';
import { PermissionMatrix } from './permission-matrix';
import type { RoleDto } from '../types/role.types';

type RoleFormDialogProps = {
  open: boolean;
  role: RoleDto | null;
  onClose: () => void;
};

export function RoleFormDialog({ open, role, onClose }: RoleFormDialogProps) {
  const isEdit = role !== null;
  const { toast } = useToast();
  const permissions = usePermissions();
  const { createRole, updateRole } = useRoleMutations();
  const mutation = isEdit ? updateRole : createRole;

  const {
    register,
    handleSubmit,
    reset,
    watch,
    setValue,
    formState: { errors },
  } = useForm<CreateRoleInput>({ resolver: zodResolver(createRoleSchema) });

  useEffect(() => {
    if (!open) return;
    reset({
      name: role?.name ?? '',
      description: role?.description ?? '',
      permissionIds: role?.permissions.map((permission) => permission.id) ?? [],
    });
  }, [open, role, reset]);

  const selectedPermissionIds = watch('permissionIds') ?? [];

  const onSubmit = (values: CreateRoleInput) => {
    const options = {
      onSuccess: () => { toast(isEdit ? 'نقش ویرایش شد' : 'نقش ساخته شد'); onClose(); },
      onError: (error: Error) => toast(error.message, 'error'),
    };

    if (isEdit) {
      updateRole.mutate({ roleId: role.id, input: values }, options);
    } else {
      createRole.mutate(values, options);
    }
  };

  return (
    <Dialog open={open} onClose={onClose} title={isEdit ? 'ویرایش نقش' : 'نقش جدید'}>
      <form onSubmit={handleSubmit(onSubmit)} className="flex flex-col gap-3.5" noValidate>
        <div className="flex flex-col gap-1.5">
          <Label htmlFor="roleName">نام نقش</Label>
          <Input id="roleName" placeholder="مثلاً: تعمیرکار" {...register('name')} />
          {errors.name && <p className="text-xs text-destructive">{errors.name.message}</p>}
        </div>

        <div className="flex flex-col gap-1.5">
          <Label htmlFor="roleDescription">توضیح (اختیاری)</Label>
          <Textarea id="roleDescription" rows={2} {...register('description')} />
        </div>

        <div className="flex flex-col gap-1.5">
          <Label>دسترسی‌ها</Label>
          {permissions.data && (
            <PermissionMatrix
              permissions={permissions.data}
              selectedIds={selectedPermissionIds}
              onChange={(ids) => setValue('permissionIds', ids, { shouldValidate: true })}
            />
          )}
          {errors.permissionIds && (
            <p className="text-xs text-destructive">{errors.permissionIds.message}</p>
          )}
        </div>

        <Button type="submit" disabled={mutation.isPending}>
          {mutation.isPending && <Loader2 className="h-4 w-4 animate-spin" />}
          {isEdit ? 'ذخیره تغییرات' : 'ساخت نقش'}
        </Button>
      </form>
    </Dialog>
  );
}
