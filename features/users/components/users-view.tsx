'use client';

import { useState } from 'react';
import { Plus, Search } from 'lucide-react';
import { Button } from '@/shared/components/ui/button';
import { Input } from '@/shared/components/ui/input';
import { Dialog } from '@/shared/components/ui/dialog';
import { useToast } from '@/shared/components/providers/toast-provider';
import { useDebouncedValue } from '@/shared/hooks/use-debounced-value';
import { cn } from '@/shared/lib/cn';
import { useUsers } from '../hooks/use-users';
import { useUserMutations } from '../hooks/use-user-mutations';
import { UserList } from './user-list';
import { UserFormDialog } from './user-form-dialog';
import type { UserDto } from '../types/user.types';

type FilterValue = 'all' | 'true' | 'false';

const FILTER_CHIPS: { value: FilterValue; label: string }[] = [
  { value: 'all', label: 'همه' },
  { value: 'true', label: 'فعال' },
  { value: 'false', label: 'غیرفعال' },
];

export function UsersView() {
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<FilterValue>('all');
  const [page, setPage] = useState(1);
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [formUser, setFormUser] = useState<UserDto | null>(null);
  const [deleteTarget, setDeleteTarget] = useState<UserDto | null>(null);

  const { toast } = useToast();
  const debouncedSearch = useDebouncedValue(search);
  const { deleteUser } = useUserMutations();

  const query = useUsers({
    page,
    search: debouncedSearch || undefined,
    isActive: filter === 'all' ? undefined : filter,
  });

  const totalPages = query.data ? Math.max(1, Math.ceil(query.data.total / query.data.pageSize)) : 1;

  const handleDelete = () => {
    if (!deleteTarget) return;
    deleteUser.mutate(deleteTarget.id, {
      onSuccess: () => { toast('کاربر حذف شد'); setDeleteTarget(null); },
      onError: (error) => toast(error.message, 'error'),
    });
  };

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <h1 className="text-xl font-extrabold">کاربران</h1>
        <Button
          className="h-10 w-auto px-4 text-[13px]"
          onClick={() => { setFormUser(null); setIsFormOpen(true); }}
        >
          <Plus className="h-4 w-4" />
          کاربر جدید
        </Button>
      </div>

      <div className="relative">
        <Search className="absolute right-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
        <Input
          className="pr-9"
          placeholder="جستجوی نام یا موبایل…"
          value={search}
          onChange={(event) => { setSearch(event.target.value); setPage(1); }}
        />
      </div>

      <div className="flex gap-2">
        {FILTER_CHIPS.map((chip) => (
          <button
            key={chip.value}
            type="button"
            onClick={() => { setFilter(chip.value); setPage(1); }}
            className={cn(
              'rounded-full border px-3.5 py-1.5 text-xs font-semibold',
              filter === chip.value
                ? 'border-primary bg-accent text-accent-foreground'
                : 'border-border bg-card text-muted-foreground',
            )}
          >
            {chip.label}
          </button>
        ))}
      </div>

      <UserList
        users={query.data?.items ?? []}
        isLoading={query.isLoading}
        onEdit={(user) => { setFormUser(user); setIsFormOpen(true); }}
        onDelete={setDeleteTarget}
      />

      {totalPages > 1 && (
        <div className="flex items-center justify-center gap-3 text-sm">
          <Button
            variant="outline"
            className="h-9 w-auto px-4 text-xs"
            disabled={page <= 1}
            onClick={() => setPage((current) => current - 1)}
          >
            قبلی
          </Button>
          <span className="font-semibold text-muted-foreground">
            صفحه {page} از {totalPages}
          </span>
          <Button
            variant="outline"
            className="h-9 w-auto px-4 text-xs"
            disabled={page >= totalPages}
            onClick={() => setPage((current) => current + 1)}
          >
            بعدی
          </Button>
        </div>
      )}

      <UserFormDialog open={isFormOpen} user={formUser} onClose={() => setIsFormOpen(false)} />

      <Dialog
        open={deleteTarget !== null}
        onClose={() => setDeleteTarget(null)}
        title="حذف کاربر؟"
      >
        <p className="mb-4 text-sm text-muted-foreground">
          کاربر «{deleteTarget?.name}» حذف می‌شود. این عملیات قابل بازگشت نیست.
        </p>
        <div className="flex gap-2">
          <Button variant="destructive" onClick={handleDelete} disabled={deleteUser.isPending}>
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
