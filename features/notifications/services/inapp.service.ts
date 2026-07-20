import {
  createInAppNotification,
  listInAppNotifications,
  countUnread,
  markAsRead,
  markAllAsRead,
} from '../repositories/inapp.repository';

export async function pushInAppNotification(input: {
  userId: string;
  title: string;
  message: string;
  entityType: string;
  entityId: string;
}) {
  try {
    await createInAppNotification(input);
  } catch (error) {
    console.error('[pushInAppNotification]', error);
  }
}

export async function getInboxService(userId: string) {
  const [items, unread] = await Promise.all([
    listInAppNotifications(userId),
    countUnread(userId),
  ]);

  return {
    unread,
    items: items.map((item) => ({
      id: item.id,
      title: item.title,
      message: item.message,
      isRead: item.isRead,
      entityType: item.entityType,
      entityId: item.entityId,
      createdAt: item.createdAt,
    })),
  };
}

export async function markReadService(userId: string, notificationId: string) {
  await markAsRead(userId, notificationId);
}

export async function markAllReadService(userId: string) {
  await markAllAsRead(userId);
}
