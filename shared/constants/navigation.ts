import {
  LayoutDashboard,
  Wrench,
  Users,
  ShieldCheck,
  type LucideIcon,
} from 'lucide-react';

export type NavItem = {
  href: string;
  label: string;
  icon: LucideIcon;
  /** کد Permission — مرجع: features/permissions/constants/permission-codes.constants.ts */
  permission?: string;
};

// آیتم‌های ناوبری بر اساس Permission کاربر فیلتر می‌شوند (docs/14-ui-design-brief.md)
export const NAV_ITEMS: NavItem[] = [
  { href: '/dashboard', label: 'داشبورد', icon: LayoutDashboard },
  { href: '/repairs', label: 'پذیرش', icon: Wrench, permission: 'VIEW_REPAIR' },
  { href: '/users', label: 'کاربران', icon: Users, permission: 'VIEW_USER' },
  { href: '/roles', label: 'نقش‌ها', icon: ShieldCheck, permission: 'ASSIGN_ROLE' },
];
