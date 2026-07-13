import { NextResponse } from 'next/server';

// فرمت پاسخ طبق docs/08-api-conventions.md
type ApiFieldError = { field?: string; message: string };

export function apiSuccess<T>(data: T, status = 200) {
  return NextResponse.json({ success: true, data }, { status });
}

export function apiError(message: string, status = 400, errors: ApiFieldError[] = []) {
  return NextResponse.json({ success: false, message, errors }, { status });
}
