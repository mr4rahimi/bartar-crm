import { prisma } from '@/shared/lib/prisma';

export async function createInAppNotification(input: {
  userId: string;
  title: string;
  message: string;
  entityType: string;
  entityId: string;
}) {
  return prisma.notification.create({
    data: { ...input, channel: 'IN_APP', status: 'SENT', type: input.title },
  });
}

export async function listInAppNotifications(userId: string) {
  return prisma.notification.findMany({
    where: { userId, channel: 'IN_APP' },
    orderBy: { createdAt: 'desc' },
    take: 30,
  });
}

export async function countUnread(userId: string) {
  return prisma.notification.count({
    where: { userId, channel: 'IN_APP', isRead: false },
  });
}

export async function markAsRead(userId: string, notificationId: string) {
  return prisma.notification.updateMany({
    where: { id: notificationId, userId },
    data: { isRead: true },
  });
}

export async function markAllAsRead(userId: string) {
  return prisma.notification.updateMany({
    where: { userId, channel: 'IN_APP', isRead: false },
    data: { isRead: true },
  });
}
