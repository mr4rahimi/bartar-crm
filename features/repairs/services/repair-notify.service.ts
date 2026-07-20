import { sendPatternSms } from '@/features/notifications/services/sms-provider.service';
import { pushInAppNotification } from '@/features/notifications/services/inapp.service';
import { createNotificationLog } from '@/features/notifications/repositories/notification.repository';
import { findRecipientsByPermissions } from '@/features/notifications/repositories/notification.repository';
import { SMS_PATTERNS } from '@/features/notifications/constants/sms.constants';
import type { TicketAction } from '../constants/workflow.constants';

type NotifyParams = {
  action: TicketAction;
  ticketId: string;
  ticketNumber: string;
  deviceTitle: string;
  assignedToId: string | null;
  assignedToName: string | null;
  assignedToPhone?: string | null;
  actorId: string;
  actorName: string;
  assignedById: string | null;
  reason?: string | null;
};

/** اطلاع‌رسانی رویدادهای جریان تعمیر — غیرمسدودکننده */
export async function notifyRepairEvent(params: NotifyParams) {
  try {
    // ارجاع/تغییر تعمیرکار/ارجاع مجدد → پیامک + اعلان به تعمیرکار مقصد
    if (['ASSIGN', 'REASSIGN', 'HANDOFF'].includes(params.action) && params.assignedToId) {
      await pushInAppNotification({
        userId: params.assignedToId,
        title: 'ارجاع دستگاه',
        message: `دستگاه ${params.deviceTitle} (پذیرش ${params.ticketNumber}) به شما ارجاع شد`,
        entityType: 'RepairTicket',
        entityId: params.ticketId,
      });

      if (params.assignedToPhone && SMS_PATTERNS.ASSIGNED) {
        const result = await sendPatternSms({
          patternCode: SMS_PATTERNS.ASSIGNED,
          recipient: params.assignedToPhone,
          attributes: { reception: params.ticketNumber, device: params.deviceTitle },
        });
        await createNotificationLog({
          userId: params.assignedToId,
          title: 'REPAIR_ASSIGNED',
          message: `ارجاع دستگاه ${params.ticketNumber}`,
          status: result.ok ? 'SENT' : result.skipped ? 'SKIPPED' : 'FAILED',
          recipient: params.assignedToPhone,
          patternCode: SMS_PATTERNS.ASSIGNED,
          providerRef: result.ok ? result.providerRef : null,
          error: result.ok ? null : result.error,
          entityType: 'RepairTicket',
          entityId: params.ticketId,
        });
      }
    }

    // تحویل گرفتن → اعلان به ارجاع‌دهنده
    if (params.action === 'ACCEPT' && params.assignedById) {
      await pushInAppNotification({
        userId: params.assignedById,
        title: 'تحویل دستگاه',
        message: `${params.actorName} دستگاه پذیرش ${params.ticketNumber} را تحویل گرفت`,
        entityType: 'RepairTicket',
        entityId: params.ticketId,
      });
    }

    // بازگشت به پذیرش → اعلان به ارجاع‌دهنده و مسئولان پذیرش
    if (params.action === 'RETURN_TO_RECEPTION') {
      const receptionists = await findRecipientsByPermissions(['ASSIGN_REPAIR']);
      const targets = new Set<string>();
      if (params.assignedById) targets.add(params.assignedById);
      receptionists.forEach((user) => targets.add(user.id));
      targets.delete(params.actorId);

      for (const userId of targets) {
        await pushInAppNotification({
          userId,
          title: 'بازگشت به پذیرش',
          message: `دستگاه پذیرش ${params.ticketNumber} توسط ${params.actorName} به پذیرش بازگردانده شد${params.reason ? ` (${params.reason})` : ''}`,
          entityType: 'RepairTicket',
          entityId: params.ticketId,
        });
      }
    }
  } catch (error) {
    console.error('[notifyRepairEvent]', error);
  }
}

export function notifyRepairEventAsync(params: NotifyParams) {
  void notifyRepairEvent(params);
}
