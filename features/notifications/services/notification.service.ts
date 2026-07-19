import type { PartRequestStatus } from '@prisma/client';
import {
  findRecipientsByPermissions,
  findRecipientById,
  createNotificationLog,
  type SmsRecipient,
} from '../repositories/notification.repository';
import { sendPatternSms } from './sms-provider.service';
import { STATUS_RULES, ADMIN_RULE, type SmsRule } from '../constants/sms.constants';
import { PART_REQUEST_STATUS_LABELS } from '@/shared/constants/part-request-status';

export type PartRequestNotificationPayload = {
  requestId: string;
  status: PartRequestStatus;
  receptionNumber: string;
  partName: string;
  modelName: string | null;
  announcedPrice: number | null;
  createdById: string;
};

function buildAttributes(
  rule: SmsRule,
  payload: PartRequestNotificationPayload,
): Record<string, string> {
  const values: Record<string, string> = {
    reception: payload.receptionNumber,
    part: payload.partName,
    model: payload.modelName ?? '-',
    price: payload.announcedPrice ? payload.announcedPrice.toLocaleString('en-US') : '-',
    status: PART_REQUEST_STATUS_LABELS[payload.status],
  };

  return Object.fromEntries(rule.attributes.map((key) => [key, values[key] ?? '-']));
}

async function resolveRecipients(
  rule: SmsRule,
  payload: PartRequestNotificationPayload,
): Promise<SmsRecipient[]> {
  const recipients: SmsRecipient[] = [];

  if (rule.includeCreator) {
    const creator = await findRecipientById(payload.createdById);
    if (creator) recipients.push(creator);
  }

  if (rule.permissions?.length) {
    recipients.push(...(await findRecipientsByPermissions(rule.permissions)));
  }

  return recipients;
}

async function dispatch(
  rule: SmsRule,
  payload: PartRequestNotificationPayload,
  recipients: SmsRecipient[],
) {
  const attributes = buildAttributes(rule, payload);
  const title = `PART_REQUEST_${payload.status}`;
  const message = Object.entries(attributes)
    .map(([key, value]) => `${key}: ${value}`)
    .join(' | ');

  for (const recipient of recipients) {
    const result = await sendPatternSms({
      patternCode: rule.patternCode,
      recipient: recipient.phone,
      attributes,
    });

    await createNotificationLog({
      userId: recipient.id,
      title,
      message,
      status: result.ok ? 'SENT' : result.skipped ? 'SKIPPED' : 'FAILED',
      recipient: recipient.phone,
      patternCode: rule.patternCode,
      providerRef: result.ok ? result.providerRef : null,
      error: result.ok ? null : result.error,
      entityType: 'PartRequest',
      entityId: payload.requestId,
    });
  }
}

/**
 * اطلاع‌رسانی رویداد درخواست قطعه.
 * هرگز throw نمی‌کند — خطای پیامک نباید جریان اصلی را متوقف کند.
 */
export async function notifyPartRequestEvent(payload: PartRequestNotificationPayload) {
  try {
    const sentPhones = new Set<string>();

    // ۱) پترن اختصاصی مرحله (اولویت با گیرنده‌ی خاص‌تر)
    const rule = STATUS_RULES[payload.status];
    if (rule?.patternCode) {
      const recipients = (await resolveRecipients(rule, payload)).filter((recipient) => {
        if (sentPhones.has(recipient.phone)) return false;
        sentPhones.add(recipient.phone);
        return true;
      });
      await dispatch(rule, payload, recipients);
    }

    // ۲) سوپر ادمین — همه‌ی تغییرات وضعیت (بدون ارسال تکراری)
    if (ADMIN_RULE.patternCode) {
      const admins = (await resolveRecipients(ADMIN_RULE, payload)).filter((recipient) => {
        if (sentPhones.has(recipient.phone)) return false;
        sentPhones.add(recipient.phone);
        return true;
      });
      await dispatch(ADMIN_RULE, payload, admins);
    }
  } catch (error) {
    console.error('[notifyPartRequestEvent]', error);
  }
}

/** فراخوانی غیرمسدودکننده از سرویس‌های دیگر */
export function notifyPartRequestEventAsync(payload: PartRequestNotificationPayload) {
  void notifyPartRequestEvent(payload);
}
