import { prisma } from '@/shared/lib/prisma';

type CreateActivityLogInput = {
  userId: string;
  action: string;
  entityType: string;
  entityId: string;
  ip?: string | null;
  device?: string | null;
};

export async function createActivityLog(input: CreateActivityLogInput) {
  return prisma.activityLog.create({ data: input });
}
