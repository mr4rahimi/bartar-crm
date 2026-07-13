import { prisma } from '@/shared/lib/prisma';
import type { Prisma } from '@prisma/client';

export type CreateActivityLogInput = {
  userId: string;
  action: string;
  entityType: string;
  entityId: string;
  previousValue?: Prisma.InputJsonValue;
  newValue?: Prisma.InputJsonValue;
  ip?: string | null;
  device?: string | null;
};

export async function createActivityLog(input: CreateActivityLogInput) {
  return prisma.activityLog.create({ data: input });
}
