import { PrismaClient } from '@prisma/client';

// جلوگیری از ساخت چندین instance در حالت dev (Hot Reload)
// طبق 11-AI_INSTRUCTIONS.md: Prisma فقط داخل Repository استفاده می‌شود.

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined;
};

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['warn', 'error'] : ['error'],
  });

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma;
}
