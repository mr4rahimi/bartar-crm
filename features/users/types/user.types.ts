export type UserRoleDto = {
  id: string;
  name: string;
};

export type UserDto = {
  id: string;
  name: string;
  phone: string;
  email: string | null;
  isActive: boolean;
  smsEnabled: boolean;
  roles: UserRoleDto[];
  createdAt: Date;
};
