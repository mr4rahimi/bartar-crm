export const PERMISSION_GROUP_LABELS: Record<string, string> = {
  Authentication: 'احراز هویت',
  Repair: 'تعمیرات',
  'Part Request': 'درخواست قطعه',
  Purchase: 'خرید',
  Pricing: 'قیمت‌ها',
  Vendor: 'فروشندگان',
  Users: 'کاربران',
  Roles: 'نقش‌ها',
  Permission: 'دسترسی‌ها',
  Logs: 'لاگ‌ها',
  Reports: 'گزارش‌ها',
  Settings: 'تنظیمات',
};

export const PERMISSION_LABELS: Record<string, string> = {
  LOGIN: 'ورود',
  LOGOUT: 'خروج',
  CREATE_REPAIR: 'ثبت تیکت تعمیر',
  EDIT_REPAIR: 'ویرایش تیکت',
  VIEW_REPAIR: 'مشاهده تیکت‌ها',
  DELETE_REPAIR: 'حذف تیکت',
  CREATE_PART_REQUEST: 'ثبت درخواست قطعه',
  EDIT_PART_REQUEST: 'ویرایش درخواست',
  DELETE_PART_REQUEST: 'حذف درخواست',
  VIEW_PART_REQUEST: 'مشاهده درخواست‌ها',
  CHANGE_STATUS: 'تغییر وضعیت',
  START_PURCHASE: 'شروع خرید',
  REGISTER_PURCHASE: 'ثبت خرید',
  EDIT_PURCHASE: 'ویرایش خرید',
  RETURN_PURCHASE: 'ثبت مرجوعی',
  NOT_FOUND: 'ثبت عدم موجودی',
  VIEW_PRICE: 'مشاهده قیمت‌ها',
  EDIT_PRICE: 'ویرایش قیمت',
  VIEW_PRICE_HISTORY: 'مشاهده تاریخچه قیمت',
  CREATE_VENDOR: 'ساخت فروشنده',
  EDIT_VENDOR: 'ویرایش فروشنده',
  DELETE_VENDOR: 'حذف فروشنده',
  VIEW_VENDOR: 'مشاهده فروشندگان',
  CREATE_USER: 'ساخت کاربر',
  EDIT_USER: 'ویرایش کاربر',
  DELETE_USER: 'حذف کاربر',
  VIEW_USER: 'مشاهده کاربران',
  CREATE_ROLE: 'ساخت نقش',
  EDIT_ROLE: 'ویرایش نقش',
  DELETE_ROLE: 'حذف نقش',
  ASSIGN_ROLE: 'اختصاص نقش',
  ASSIGN_PERMISSION: 'اختصاص دسترسی',
  VIEW_ACTIVITY_LOG: 'مشاهده لاگ فعالیت',
  VIEW_SYSTEM_LOG: 'مشاهده لاگ سیستم',
  VIEW_REPORTS: 'مشاهده گزارش‌ها',
  EXPORT_REPORTS: 'خروجی گزارش',
  VIEW_SETTINGS: 'مشاهده تنظیمات',
  EDIT_SETTINGS: 'ویرایش تنظیمات',
};

export function permissionLabel(code: string): string {
  return PERMISSION_LABELS[code] ?? code;
}

export function permissionGroupLabel(group: string): string {
  return PERMISSION_GROUP_LABELS[group] ?? group;
}
