/** گرد رو به پایین به مضرب step (پیش‌فرض ۱۰٬۰۰۰ تومان) — docs/15-pricing-integration.md */
export function roundDownTo(value: number, step = 10_000): number {
  return Math.floor(value / step) * step;
}
