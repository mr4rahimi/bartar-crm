const BASE_URL = process.env.IRANPAYAMAK_BASE_URL ?? 'https://api.iranpayamak.com';
const API_KEY = process.env.IRANPAYAMAK_API_KEY ?? '';
const LINE_NUMBER = process.env.IRANPAYAMAK_LINE_NUMBER ?? '';
const NUMBER_FORMAT = process.env.IRANPAYAMAK_NUMBER_FORMAT ?? 'en';
const IS_ENABLED = process.env.SMS_ENABLED === 'true';
const TIMEOUT_MS = 10_000;

export type SmsSendResult =
  | { ok: true; providerRef: string | null }
  | { ok: false; skipped: boolean; error: string };

/**
 * ارسال پیامک پترن‌محور — POST /ws/v1/sms/pattern
 * هرگز throw نمی‌کند؛ خطا به‌صورت نتیجه برمی‌گردد تا جریان اصلی متوقف نشود.
 */
export async function sendPatternSms(params: {
  patternCode: string;
  recipient: string;
  attributes: Record<string, string>;
}): Promise<SmsSendResult> {
  if (!IS_ENABLED) {
    return { ok: false, skipped: true, error: 'سرویس پیامک غیرفعال است (SMS_ENABLED)' };
  }
  if (!API_KEY || !LINE_NUMBER) {
    return { ok: false, skipped: true, error: 'کلید API یا شماره خط تنظیم نشده است' };
  }
  if (!params.patternCode) {
    return { ok: false, skipped: true, error: 'کد پترن تنظیم نشده است' };
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);

  try {
    const response = await fetch(`${BASE_URL}/ws/v1/sms/pattern`, {
      method: 'POST',
      headers: {
        'Api-Key': API_KEY,
        'Content-Type': 'application/json',
        Accept: 'application/json',
      },
      body: JSON.stringify({
        code: params.patternCode,
        recipient: params.recipient,
        attributes: params.attributes,
        line_number: LINE_NUMBER,
        number_format: NUMBER_FORMAT,
      }),
      signal: controller.signal,
    });

    const payload = (await response.json().catch(() => null)) as
      | { status?: string; data?: unknown; messages?: unknown }
      | null;

    if (!response.ok) {
      console.error('[SMS DEBUG]', response.status, JSON.stringify(payload));
    }  

    if (!response.ok || payload?.status !== 'success') {
      const detail =
        typeof payload?.messages === 'string'
          ? payload.messages
          : JSON.stringify(payload?.messages ?? response.statusText);
      return { ok: false, skipped: false, error: `${response.status}: ${detail}` };
    }

    return { ok: true, providerRef: payload.data ? String(payload.data) : null };
  } catch (error) {
    const message = error instanceof Error ? error.message : 'خطای نامشخص در ارسال پیامک';
    return { ok: false, skipped: false, error: message };
  } finally {
    clearTimeout(timer);
  }
}
