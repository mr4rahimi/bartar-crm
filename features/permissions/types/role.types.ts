export type RolePermissionDto = {
  id: string;
  code: string;
  group: string;
};

export type RoleDto = {
  id: string;
  name: string;
  description: string | null;
  permissions: RolePermissionDto[];
  userCount: number;
};
