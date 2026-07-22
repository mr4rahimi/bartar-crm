import { sendPatternSms } from '@/features/notifications/services/sms-provider.service';
import { pushInAppNotification } from '@/features/notifications/services/inapp.service';
import {
  createNotificationLog,
  findRecipientsByPermissions,
} from '@/features/notifications/repositories/notification.repository';
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
  /** برای پیامک آماده‌بودن دستگاه به مشتری */
  customerName?: string;
  customerPhone?: string;
  notifyCustomer?: boolean;
};

/** اطلاع‌رسانی رویدادهای جریان تعمیر — غیرمسدودکننده */
export async function notifyRepairEvent(params: NotifyParams) {
  try {
    // ----- ارجاع به تعمیرکار: پیامک + اعلان -----
    if (
      ['ASSIGN', 'REASSIGN', 'HANDOFF', 'MARK_REPAIRED'].includes(params.action) &&
      params.assignedToId &&
      params.assignedToId !== params.actorId
    ) {
      const isQuality = params.action === 'MARK_REPAIRED';
      await pushInAppNotification({
        userId: params.assignedToId,
        title: isQuality ? 'کنترل کیفیت' : 'ارجاع دستگاه',
        message: isQuality
          ? `دستگاه ${params.deviceTitle} (پذیرش ${params.ticketNumber}) برای کنترل کیفیت به شما ارجاع شد`
          : `دستگاه ${params.deviceTitle} (پذیرش ${params.ticketNumber}) به شما ارجاع شد`,
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

    // ----- تحویل گرفتن تعمیرکار: اعلان به ارجاع‌دهنده -----
    if (params.action === 'ACCEPT' && params.assignedById) {
      await pushInAppNotification({
        userId: params.assignedById,
        title: 'تحویل دستگاه',
        message: `${params.actorName} دستگاه پذیرش ${params.ticketNumber} را تحویل گرفت`,
        entityType: 'RepairTicket',
        entityId: params.ticketId,
      });
    }

    // ----- آماده تحویل / عدم تعمیر: اعلان به پذیرش -----
    if (['PASS_QUALITY', 'MARK_UNREPAIRABLE'].includes(params.action)) {
      const isUnrepairable = params.action === 'MARK_UNREPAIRABLE';
      const receptionists = await findRecipientsByPermissions(['ASSIGN_REPAIR']);
      for (const user of receptionists) {
        if (user.id === params.actorId) continue;
        await pushInAppNotification({
          userId: user.id,
          title: isUnrepairable ? 'عدم تعمیر' : 'آماده تحویل',
          message: isUnrepairable
            ? `دستگاه پذیرش ${params.ticketNumber} تعمیر نشد${params.reason ? ` (${params.reason})` : ''}`
            : `دستگاه پذیرش ${params.ticketNumber} آماده تحویل است`,
          entityType: 'RepairTicket',
          entityId: params.ticketId,
        });
      }
    }

    // ----- رد کنترل کیفیت: اعلان به تعمیرکار -----
    if (params.action === 'FAIL_QUALITY' && params.assignedToId) {
      await pushInAppNotification({
        userId: params.assignedToId,
        title: 'رد کنترل کیفیت',
        message: `دستگاه پذیرش ${params.ticketNumber} در کنترل کیفیت رد شد${params.reason ? ` (${params.reason})` : ''}`,
        entityType: 'RepairTicket',
        entityId: params.ticketId,
      });
    }

    // ----- پیامک آماده‌بودن به مشتری (با تایید پذیرش) -----
    if (
      params.action === 'RECEIVE_BY_RECEPTION' &&
      params.notifyCustomer &&
      params.customerPhone &&
      SMS_PATTERNS.READY
    ) {
      const result = await sendPatternSms({
        patternCode: SMS_PATTERNS.READY,
        recipient: params.customerPhone,
        attributes: {
          name: params.customerName ?? '',
          reception: params.ticketNumber,
        },
      });
      await createNotificationLog({
        userId: params.actorId,
        title: 'DEVICE_READY',
        message: `اطلاع آماده‌بودن دستگاه ${params.ticketNumber} به مشتری`,
        status: result.ok ? 'SENT' : result.skipped ? 'SKIPPED' : 'FAILED',
        recipient: params.customerPhone,
        patternCode: SMS_PATTERNS.READY,
        providerRef: result.ok ? result.providerRef : null,
        error: result.ok ? null : result.error,
        entityType: 'RepairTicket',
        entityId: params.ticketId,
      });
    }

    // ----- بازگشت به پذیرش: اعلان به ارجاع‌دهنده و مسئولان -----
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
