import { prisma } from '@/shared/lib/prisma';
import type { NotificationStatus } from '@prisma/client';

export type SmsRecipient = { id: string; name: string; phone: string };

/** کاربران فعالِ دارای حداقل یکی از Permissionها که پیامک را خاموش نکرده‌اند */
export async function findRecipientsByPermissions(
  permissionCodes: string[],
): Promise<SmsRecipient[]> {
  if (permissionCodes.length === 0) return [];

  const users = await prisma.user.findMany({
    where: {
      deletedAt: null,
      isActive: true,
      smsEnabled: true,
      roles: {
        some: {
          role: {
            deletedAt: null,
            permissions: { some: { permission: { code: { in: permissionCodes } } } },
          },
        },
      },
    },
    select: { id: true, name: true, phone: true },
  });

  return users;
}

export async function findRecipientById(userId: string): Promise<SmsRecipient | null> {
  return prisma.user.findFirst({
    where: { id: userId, deletedAt: null, isActive: true, smsEnabled: true },
    select: { id: true, name: true, phone: true },
  });
}

export async function createNotificationLog(input: {
  userId: string;
  title: string;
  message: string;
  status: NotificationStatus;
  recipient: string;
  patternCode: string;
  providerRef?: string | null;
  error?: string | null;
  entityType: string;
  entityId: string;
}) {
  return prisma.notification.create({
    data: { ...input, channel: 'SMS', type: input.title },
  });
}
