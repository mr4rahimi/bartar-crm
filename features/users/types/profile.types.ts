export type ProfileDto = {
  id: string;
  name: string;
  phone: string;
  avatarUrl: string | null;
  roles: string[];
  smsEnabled: boolean;
  createdAt: Date;
};
