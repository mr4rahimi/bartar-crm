'use client';

import { useMemo } from 'react';
import {
  permissionLabel,
  permissionGroupLabel,
} from '../constants/permission-labels.constants';
import type { PermissionDto } from '../hooks/use-permissions';

type PermissionMatrixProps = {
  permissions: PermissionDto[];
  selectedIds: string[];
  onChange: (ids: string[]) => void;
};

// چک‌باکس‌های گروه‌بندی‌شده با «انتخاب همه‌ی گروه» — مطابق ماکاپ ui/
export function PermissionMatrix({ permissions, selectedIds, onChange }: PermissionMatrixProps) {
  const groups = useMemo(() => {
    const map = new Map<string, PermissionDto[]>();
    for (const permission of permissions) {
      const list = map.get(permission.group) ?? [];
      list.push(permission);
      map.set(permission.group, list);
    }
    return [...map.entries()];
  }, [permissions]);

  const toggleOne = (id: string) => {
    onChange(
      selectedIds.includes(id)
        ? selectedIds.filter((selectedId) => selectedId !== id)
        : [...selectedIds, id],
    );
  };

  const toggleGroup = (groupPermissions: PermissionDto[], selectAll: boolean) => {
    const groupIds = groupPermissions.map((permission) => permission.id);
    const withoutGroup = selectedIds.filter((id) => !groupIds.includes(id));
    onChange(selectAll ? [...withoutGroup, ...groupIds] : withoutGroup);
  };

  return (
    <div className="space-y-2.5">
      {groups.map(([group, groupPermissions]) => {
        const selectedCount = groupPermissions.filter((permission) =>
          selectedIds.includes(permission.id),
        ).length;
        const allSelected = selectedCount === groupPermissions.length;

        return (
          <div key={group} className="rounded-md border border-border bg-background p-3">
            <label className="flex cursor-pointer items-center justify-between pb-2">
              <span className="text-[13px] font-bold">{permissionGroupLabel(group)}</span>
              <span className="flex items-center gap-2 text-xs font-semibold text-muted-foreground">
                همه
                <input
                  type="checkbox"
                  className="h-4 w-4 accent-[#22c55e]"
                  checked={allSelected}
                  ref={(element) => {
                    if (element) element.indeterminate = selectedCount > 0 && !allSelected;
                  }}
                  onChange={(event) => toggleGroup(groupPermissions, event.target.checked)}
                />
              </span>
            </label>
            <div className="grid grid-cols-1 gap-1.5 border-t border-border pt-2 sm:grid-cols-2">
              {groupPermissions.map((permission) => (
                <label
                  key={permission.id}
                  className="flex cursor-pointer items-center gap-2 text-[12.5px] font-medium"
                >
                  <input
                    type="checkbox"
                    className="h-4 w-4 accent-[#22c55e]"
                    checked={selectedIds.includes(permission.id)}
                    onChange={() => toggleOne(permission.id)}
                  />
                  {permissionLabel(permission.code)}
                </label>
              ))}
            </div>
          </div>
        );
      })}
    </div>
  );
}
