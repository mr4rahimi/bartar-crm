import {
  createActivityLog,
  type CreateActivityLogInput,
} from '../repositories/activity-log.repository';

// نقطه‌ی ورود مرکزی لاگ‌نویسی — سایر فیچرها فقط از طریق همین Service لاگ ثبت می‌کنند
// (ارتباط بین فیچرها فقط از طریق Service — docs/07-folder-structure.md)
export async function logActivity(input: CreateActivityLogInput) {
  return createActivityLog(input);
}
