'use client';

import { Pencil, Trash2, Users } from 'lucide-react';
import { Badge } from '@/shared/components/ui/badge';
import { Skeleton } from '@/shared/components/ui/skeleton';
import type { UserDto } from '../types/user.types';

type UserListProps = {
  users: UserDto[];
  isLoading: boolean;
  onEdit: (user: UserDto) => void;
  onDelete: (user: UserDto) => void;
};

export function UserList({ users, isLoading, onEdit, onDelete }: UserListProps) {
  if (isLoading) {
    return (
      <div className="space-y-2">
        {[1, 2, 3, 4].map((key) => (
          <Skeleton key={key} className="h-20 w-full" />
        ))}
      </div>
    );
  }

  if (users.length === 0) {
    return (
      <div className="flex flex-col items-center gap-2 rounded-lg border border-border bg-card py-12 text-center">
        <Users className="h-8 w-8 text-muted-foreground" />
        <p className="text-sm font-semibold text-muted-foreground">کاربری یافت نشد</p>
      </div>
    );
  }

  const actionButtons = (user: UserDto) => (
    <div className="flex gap-1">
      <button
        type="button"
        onClick={() => onEdit(user)}
        className="rounded-md p-2 text-muted-foreground hover:bg-muted"
        aria-label="ویرایش"
      >
        <Pencil className="h-4 w-4" />
      </button>
      <button
        type="button"
        onClick={() => onDelete(user)}
        className="rounded-md p-2 text-destructive hover:bg-muted"
        aria-label="حذف"
      >
        <Trash2 className="h-4 w-4" />
      </button>
    </div>
  );

  return (
    <>
      {/* موبایل — کارت (مطابق ماکاپ) */}
      <div className="space-y-2 md:hidden">
        {users.map((user) => (
          <div key={user.id} className="rounded-lg border border-border bg-card p-3.5">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-2.5">
                <div className="flex h-9 w-9 items-center justify-center rounded-full bg-accent text-[13px] font-bold text-accent-foreground">
                  {user.name.charAt(0)}
                </div>
                <div>
                  <div className="text-[13.5px] font-bold">{user.name}</div>
                  <div dir="ltr" className="text-right text-[11.5px] text-muted-foreground">
                    {user.phone}
                  </div>
                </div>
              </div>
              <div className="flex items-center gap-1">
                <Badge variant={user.isActive ? 'green' : 'red'}>
                  {user.isActive ? 'فعال' : 'غیرفعال'}
                </Badge>
                {actionButtons(user)}
              </div>
            </div>
            <div className="mt-2 flex flex-wrap gap-1.5">
              {user.roles.map((role) => (
                <Badge key={role.id} variant="blue">
                  {role.name}
                </Badge>
              ))}
            </div>
          </div>
        ))}
      </div>

      {/* دسکتاپ — جدول */}
      <div className="hidden overflow-hidden rounded-lg border border-border bg-card md:block">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-border text-right text-[11.5px] font-bold text-muted-foreground">
              <th className="px-4 py-3">نام</th>
              <th className="px-4 py-3">موبایل</th>
              <th className="px-4 py-3">نقش‌ها</th>
              <th className="px-4 py-3">وضعیت</th>
              <th className="px-4 py-3">عملیات</th>
            </tr>
          </thead>
          <tbody>
            {users.map((user) => (
              <tr key={user.id} className="border-b border-border last:border-0">
                <td className="px-4 py-3 font-semibold">{user.name}</td>
                <td dir="ltr" className="px-4 py-3 text-right text-muted-foreground">
                  {user.phone}
                </td>
                <td className="px-4 py-3">
                  <div className="flex flex-wrap gap-1.5">
                    {user.roles.map((role) => (
                      <Badge key={role.id} variant="blue">
                        {role.name}
                      </Badge>
                    ))}
                  </div>
                </td>
                <td className="px-4 py-3">
                  <Badge variant={user.isActive ? 'green' : 'red'}>
                    {user.isActive ? 'فعال' : 'غیرفعال'}
                  </Badge>
                </td>
                <td className="px-4 py-3">{actionButtons(user)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}
