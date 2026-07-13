// خطاهای پایه‌ی اپلیکیشن — هر فیچر می‌تواند خطای اختصاصی خود را از AppError مشتق کند.
// statusCode مستقیماً به HTTP Status پاسخ نگاشت می‌شود (docs/08-api-conventions.md)

export class AppError extends Error {
  constructor(
    message: string,
    public readonly statusCode: number,
  ) {
    super(message);
    this.name = 'AppError';
  }
}

export class UnauthenticatedError extends AppError {
  constructor() {
    super('احراز هویت نشده‌اید', 401);
    this.name = 'UnauthenticatedError';
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'شما دسترسی لازم برای این عملیات را ندارید') {
    super(message, 403);
    this.name = 'ForbiddenError';
  }
}

export class NotFoundError extends AppError {
  constructor(message = 'موردی یافت نشد') {
    super(message, 404);
    this.name = 'NotFoundError';
  }
}

export class ConflictError extends AppError {
  constructor(message: string) {
    super(message, 409);
    this.name = 'ConflictError';
  }
}
