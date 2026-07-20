const ONES = ['', 'یک', 'دو', 'سه', 'چهار', 'پنج', 'شش', 'هفت', 'هشت', 'نه'];
const TEENS = [
  'ده', 'یازده', 'دوازده', 'سیزده', 'چهارده',
  'پانزده', 'شانزده', 'هفده', 'هجده', 'نوزده',
];
const TENS = ['', '', 'بیست', 'سی', 'چهل', 'پنجاه', 'شصت', 'هفتاد', 'هشتاد', 'نود'];
const HUNDREDS = [
  '', 'صد', 'دویست', 'سیصد', 'چهارصد',
  'پانصد', 'ششصد', 'هفتصد', 'هشتصد', 'نهصد',
];
const SCALES = ['', 'هزار', 'میلیون', 'میلیارد', 'بیلیون'];

function tripletToWords(value: number): string {
  const parts: string[] = [];
  const hundred = Math.floor(value / 100);
  const rest = value % 100;

  if (hundred > 0) parts.push(HUNDREDS[hundred] ?? '');

  if (rest >= 10 && rest < 20) {
    parts.push(TEENS[rest - 10] ?? '');
  } else {
    const ten = Math.floor(rest / 10);
    const one = rest % 10;
    if (ten > 0) parts.push(TENS[ten] ?? '');
    if (one > 0) parts.push(ONES[one] ?? '');
  }

  return parts.filter(Boolean).join(' و ');
}

/** تبدیل عدد صحیح مثبت به حروف فارسی */
export function numberToPersianWords(value: number): string {
  if (!Number.isFinite(value) || value <= 0) return 'صفر';

  const triplets: number[] = [];
  let remaining = Math.floor(value);
  while (remaining > 0) {
    triplets.push(remaining % 1000);
    remaining = Math.floor(remaining / 1000);
  }

  const parts: string[] = [];
  for (let index = triplets.length - 1; index >= 0; index--) {
    const triplet = triplets[index] ?? 0;
    if (triplet === 0) continue;
    const scale = SCALES[index] ?? '';
    parts.push(scale ? `${tripletToWords(triplet)} ${scale}` : tripletToWords(triplet));
  }

  return parts.join(' و ');
}
