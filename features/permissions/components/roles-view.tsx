'use client';

import { useState } from 'react';
import { Pencil, Plus, ShieldCheck, Trash2 } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Dialog } from '@/shared/components/ui/dialog';
import { Skeleton } from '@/shared/components/ui/skeleton';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useRoles } from '../hooks/use-roles';
import { useRoleMutations } from '../hooks/use-role-mutations';
import { RoleFormDialog } from './role-form-dialog';
import type { RoleDto } from '../types/role.types';

export function RolesView() {
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [formRole, setFormRole] = useState<RoleDto | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<RoleDto | null>(null);

  const { toast } = useToast();
  const roles = useRoles();
  const { deleteRole } = useRoleMutations();

  const handleDelete = () => {
    if (!deleteTarget) return;
    deleteRole.mutate(deleteTarget.id, {
      onSuccess: () => { toast('نقش حذف شد'); setDeleteTarget(null); },
      onError: (error) => toast(error.message, 'error'),
    });
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-extrabold">نقش‌ها و دسترسی‌ها</h1>
        <Button
          className="h-10 w-auto px-4 text-[13px]"
          onClick={() => { setFormRole(null); setIsFormOpen(true); }}
        >
          <Plus className="h-4 w-4" />
          نقش جدید
        </Button>
      </div>

      {roles.isLoading && (
        <div className="space-y-2">
          {[1, 2, 3].map((key) => (
            <Skeleton key={key} className="h-24 w-full" />
          ))}
        </div>
      )}

      {roles.data?.length === 0 && (
        <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12">
          <ShieldCheck className="h-8 w-8 text-muted-foreground" />
          <p className="text-sm font-semibold text-muted-foreground">نقشی یافت نشد</p>
        </div>
      )}

      <div className="grid grid-cols-1 gap-3 lg:grid-cols-2">
        {roles.data?.map((role) => (
          <div key={role.id} className="rounded-lg border border-border bg-card p-4">
            <div className="flex items-start justify-between">
              <div>
                <div className="text-[14.5px] font-extrabold">{role.name}</div>
                {role.description && (
                  <p className="mt-0.5 text-xs text-muted-foreground">{role.description}</p>
                )}
              </div>
              <div className="flex gap-1">
                <button
                  type="button"
                  onClick={() => { setFormRole(role); setIsFormOpen(true); }}
                  className="rounded-md p-2 text-muted-foreground hover:bg-muted"
                  aria-label="ویرایش"
                >
                  <Pencil className="h-4 w-4" />
                </button>
                <button
                  type="button"
                  onClick={() => setDeleteTarget(role)}
                  className="rounded-md p-2 text-destructive hover:bg-muted"
                  aria-label="حذف"
                >
                  <Trash2 className="h-4 w-4" />
                </button>
              </div>
            </div>
            <div className="mt-3 flex gap-2 text-[11.5px] font-bold text-muted-foreground">
              <span className="rounded-md border border-border bg-background px-2 py-1">
                {role.userCount} کاربر
              </span>
              <span className="rounded-md border border-border bg-background px-2 py-1">
                {role.permissions.length} دسترسی
              </span>
            </div>
          </div>
        ))}
      </div>

      <RoleFormDialog open={isFormOpen} role={formRole} onClose={() => setIsFormOpen(false)} />

      <Dialog open={deleteTarget !== null} onClose={() => setDeleteTarget(null)} title="حذف نقش؟">
        <p className="mb-4 text-sm text-muted-foreground">
          نقش «{deleteTarget?.name}» حذف می‌شود. نقش‌های دارای کاربر قابل حذف نیستند.
        </p>
        <div className="flex gap-2">
          <Button variant="destructive" onClick={handleDelete} disabled={deleteRole.isPending}>
            حذف
          </Button>
          <Button variant="outline" onClick={() => setDeleteTarget(null)}>
            انصراف
          </Button>
        </div>
      </Dialog>
    </div>
  );
}
