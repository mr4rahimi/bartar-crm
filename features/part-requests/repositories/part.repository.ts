import { prisma } from '@/shared/lib/prisma';

export async function listParts() {
  return prisma.part.findMany({
    where: { deletedAt: null },
    orderBy: { name: 'asc' },
  });
}

// قطعه با ورود آزاد نام — اگر نبود ساخته می‌شود
export async function upsertPartByName(name: string) {
  return prisma.part.upsert({
    where: { name },
    update: {},
    create: { name },
  });
}
