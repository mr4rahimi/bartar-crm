import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

// این فایل در Feature بعدی (Authentication) تکمیل خواهد شد.
// طبق 11-AI_INSTRUCTIONS.md: Route فقط Validate → Authorize → Call Service → Return Response

export function middleware(request: NextRequest) {
  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/purchases/:path*', '/repairs/:path*', '/settings/:path*'],
};
