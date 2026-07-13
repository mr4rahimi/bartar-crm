import type { NextRequest } from 'next/server';

export function requestContext(request: NextRequest) {
  return {
    ip: request.headers.get('x-forwarded-for'),
    device: request.headers.get('user-agent'),
  };
}
