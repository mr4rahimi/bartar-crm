// کلاینت fetch با فرمت پاسخ استاندارد docs/08-api-conventions.md
type ApiEnvelope<T> =
  | { success: true; data: T }
  | { success: false; message: string; errors: { field?: string; message: string }[] };

export async function apiFetch<T>(url: string, init?: RequestInit): Promise<T> {
  const response = await fetch(url, {
    headers: { 'Content-Type': 'application/json' },
    ...init,
  });

  const json = (await response.json()) as ApiEnvelope<T>;

  if (!json.success) {
    throw new Error(json.message);
  }

  return json.data;
}
