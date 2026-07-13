import { AppError } from './errors';
import { apiError } from './api-response';

// هیچ Error خام به کاربر نمایش داده نشود (docs/10-development-rules.md)
export function handleApiError(error: unknown, context: string) {
  if (error instanceof AppError) {
    return apiError(error.message, error.statusCode);
  }

  console.error(context, error);
  return apiError('خطای داخلی سرور', 500);
}
