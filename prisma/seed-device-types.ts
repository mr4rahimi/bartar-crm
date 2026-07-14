import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

const DEVICE_TYPES = ['موبایل', 'تبلت', 'لپ‌تاپ'];

async function main() {
  for (const name of DEVICE_TYPES) {
    await prisma.deviceType.upsert({ where: { name }, update: {}, create: { name } });
  }
  console.log(`✓ ${DEVICE_TYPES.length} نوع دستگاه seed شد`);
}

main().finally(() => prisma.$disconnect());
