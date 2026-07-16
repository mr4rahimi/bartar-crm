'use client';

import { useState } from 'react';
import { Check, Pencil, Plus, Trash2, X } from 'lucide-react';
import { Input } from '@/shared/components/ui/input';
import { useToast } from '@/shared/components/providers/toast-provider';
import type { useCatalogMutations } from '../hooks/use-catalog-admin';

type Item = { id: string; name: string };

type CatalogCardProps = {
  title: string;
  items: Item[];
  mutations: ReturnType<typeof useCatalogMutations>;
  /** فیلدهای اضافه هنگام ساخت (مثل برند/نوع دستگاه برای مدل) */
  extraCreateFields?: React.ReactNode;
  buildCreateBody?: (name: string) => Record<string, unknown> | null;
};

export function CatalogCard({
  title,
  items,
  mutations,
  extraCreateFields,
  buildCreateBody,
}: CatalogCardProps) {
  const { toast } = useToast();
  const [newName, setNewName] = useState('');
  const [editId, setEditId] = useState<string | null>(null);
  const [editName, setEditName] = useState('');

  const handleAdd = () => {
    if (!newName.trim()) return;
    const body = buildCreateBody ? buildCreateBody(newName.trim()) : { name: newName.trim() };
    if (!body) return;
    mutations.create.mutate(body, {
      onSuccess: () => { toast(`${title} افزوده شد`); setNewName(''); },
      onError: (error) => toast(error.message, 'error'),
    });
  };

  const handleUpdate = (id: string) => {
    if (!editName.trim()) return;
    mutations.update.mutate(
      { id, name: editName.trim() },
      {
        onSuccess: () => { toast('ویرایش شد'); setEditId(null); },
        onError: (error) => toast(error.message, 'error'),
      },
    );
  };

  const handleDelete = (id: string) => {
    mutations.remove.mutate(id, {
      onSuccess: () => toast('حذف شد'),
      onError: (error) => toast(error.message, 'error'),
    });
  };

  return (
    <div className="rounded-lg border border-border bg-card p-4">
      <div className="mb-3 flex items-center justify-between">
        <h3 className="text-[14px] font-extrabold">{title}</h3>
        <span className="rounded-md bg-muted px-2 py-0.5 text-[11px] font-bold text-muted-foreground">
          {items.length.toLocaleString('fa-IR')}
        </span>
      </div>

      <div className="mb-3 space-y-2">
        {extraCreateFields}
        <div className="flex gap-2">
          <Input
            placeholder={`نام ${title}…`}
            value={newName}
            onChange={(event) => setNewName(event.target.value)}
            onKeyDown={(event) => event.key === 'Enter' && handleAdd()}
          />
          <button
            type="button"
            onClick={handleAdd}
            disabled={mutations.create.isPending}
            className="flex h-11 shrink-0 items-center gap-1 rounded-md bg-primary px-3.5 text-[13px] font-bold text-primary-foreground disabled:opacity-50"
          >
            <Plus className="h-4 w-4" />
            افزودن
          </button>
        </div>
      </div>

      <div className="max-h-72 space-y-1 overflow-y-auto">
        {items.map((item) => (
          <div
            key={item.id}
            className="flex items-center gap-2 rounded-md border border-border bg-background px-3 py-2"
          >
            {editId === item.id ? (
              <>
                <Input
                  className="h-8"
                  value={editName}
                  onChange={(event) => setEditName(event.target.value)}
                  onKeyDown={(event) => event.key === 'Enter' && handleUpdate(item.id)}
                  autoFocus
                />
                <button type="button" onClick={() => handleUpdate(item.id)} className="text-primary" aria-label="ذخیره">
                  <Check className="h-4 w-4" />
                </button>
                <button type="button" onClick={() => setEditId(null)} className="text-muted-foreground" aria-label="انصراف">
                  <X className="h-4 w-4" />
                </button>
              </>
            ) : (
              <>
                <span className="flex-1 text-[13px] font-semibold">{item.name}</span>
                <button
                  type="button"
                  onClick={() => { setEditId(item.id); setEditName(item.name); }}
                  className="text-muted-foreground hover:text-foreground"
                  aria-label="ویرایش"
                >
                  <Pencil className="h-3.5 w-3.5" />
                </button>
                <button
                  type="button"
                  onClick={() => handleDelete(item.id)}
                  className="text-destructive"
                  aria-label="حذف"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                </button>
              </>
            )}
          </div>
        ))}
        {items.length === 0 && (
          <p className="py-4 text-center text-[12px] text-muted-foreground">موردی ثبت نشده</p>
        )}
      </div>
    </div>
  );
}
