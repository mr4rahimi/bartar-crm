import { PERMISSIONS } from './permission-codes.constants';

const P = PERMISSIONS;

// نگاشت اولیه‌ی نقش پیش‌فرض ← Permission، طبق توضیحات فارسی docs/06-user-roles.md
// این فقط پیش‌فرض seed است؛ ادمین بعداً می‌تواند از UI این نگاشت را تغییر دهد.
export const DEFAULT_ROLES: Record<string, { description: string; permissions: string[] }> = {
  'Super Admin': {
    description: 'دسترسی کامل به تمام سیستم',
    permissions: Object.values(P).map((p) => p.code),
  },
  Admin: {
    description: 'مدیریت کاربران، قطعات، فروشندگان، قیمت‌ها و تنظیمات',
    permissions: [
      P.CREATE_USER, P.EDIT_USER, P.DELETE_USER, P.VIEW_USER,
      P.CREATE_ROLE, P.EDIT_ROLE, P.ASSIGN_ROLE,
      P.CREATE_VENDOR, P.EDIT_VENDOR, P.DELETE_VENDOR, P.VIEW_VENDOR,
      P.VIEW_PRICE, P.EDIT_PRICE, P.VIEW_PRICE_HISTORY,
      P.VIEW_REPORTS, P.EXPORT_REPORTS,
      P.VIEW_SETTINGS, P.EDIT_SETTINGS,
      P.VIEW_ACTIVITY_LOG,
    ].map((p) => p.code),
  },
  Reception: {
    description: 'ثبت پذیرش، ثبت درخواست قطعه، تایید مشتری، بیعانه',
    permissions: [
      P.CREATE_REPAIR, P.EDIT_REPAIR, P.VIEW_REPAIR,
      P.CREATE_PART_REQUEST, P.EDIT_PART_REQUEST, P.VIEW_PART_REQUEST, P.CHANGE_STATUS,
      P.VIEW_PRICE,
    ].map((p) => p.code),
  },
  Technician: {
    description: 'ثبت درخواست قطعه، تست، مصرف، مرجوعی',
    permissions: [
      P.CREATE_PART_REQUEST, P.EDIT_PART_REQUEST, P.VIEW_PART_REQUEST, P.CHANGE_STATUS,
    ].map((p) => p.code),
  },
  Buyer: {
    description: 'صف خرید، ثبت خرید، ثبت فروشنده، ثبت قیمت',
    permissions: [
      P.VIEW_PART_REQUEST, P.START_PURCHASE, P.REGISTER_PURCHASE, P.EDIT_PURCHASE,
      P.RETURN_PURCHASE, P.NOT_FOUND, P.CREATE_VENDOR, P.VIEW_VENDOR,
      P.VIEW_PRICE, P.EDIT_PRICE,
    ].map((p) => p.code),
  },
  'Pricing Operator': {
    description: 'مدیریت قیمت قطعات و تاریخچه قیمت',
    permissions: [P.VIEW_PRICE, P.EDIT_PRICE, P.VIEW_PRICE_HISTORY].map((p) => p.code),
  },
  Viewer: {
    description: 'فقط مشاهده',
    permissions: [
      P.VIEW_REPAIR, P.VIEW_PART_REQUEST, P.VIEW_VENDOR, P.VIEW_PRICE, P.VIEW_REPORTS,
    ].map((p) => p.code),
  },
};
