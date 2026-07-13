export type AuthenticatedUser = {
  id: string;
  name: string;
  phone: string;
  email: string | null;
  permissions: string[];
};
