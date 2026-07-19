import { z } from 'zod';

// نگاشت سراسری پیام‌های خطای Zod به فارسی (import برای side-effect)
const persianErrorMap: z.ZodErrorMap = (issue) => {
  switch (issue.code) {
    case z.ZodIssueCode.invalid_type:
      if (issue.received === 'undefined' || issue.received === 'null') {
        return { message: 'این فیلد الزامی است' };
      }
      return { message: 'مقدار واردشده معتبر نیست' };

    case z.ZodIssueCode.too_small:
      if (issue.type === 'string') {
        return {
          message:
            issue.minimum === 1 ? 'این فیلد الزامی است' : `حداقل ${issue.minimum} کاراکتر لازم است`,
        };
      }
      if (issue.type === 'array') return { message: 'حداقل یک مورد انتخاب کنید' };
      return { message: 'مقدار واردشده کوچک‌تر از حد مجاز است' };

    case z.ZodIssueCode.too_big:
      if (issue.type === 'string') return { message: `حداکثر ${issue.maximum} کاراکتر مجاز است` };
      return { message: 'مقدار واردشده بزرگ‌تر از حد مجاز است' };

    case z.ZodIssueCode.invalid_enum_value:
      return { message: 'گزینه انتخاب‌شده معتبر نیست' };

    case z.ZodIssueCode.invalid_string:
      return { message: 'قالب واردشده معتبر نیست' };

    case z.ZodIssueCode.invalid_date:
      return { message: 'تاریخ واردشده معتبر نیست' };

    default:
      return { message: 'مقدار واردشده معتبر نیست' };
  }
};

z.setErrorMap(persianErrorMap);
