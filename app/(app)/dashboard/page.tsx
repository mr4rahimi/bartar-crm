const STAT_CARDS = [
  { label: 'درخواست‌های باز', icon: '📋' },
  { label: 'در صف خرید', icon: '🛒' },
  { label: 'خریدهای امروز', icon: '✅' },
  { label: 'عدم موجودی', icon: '⚠️' },
];

export default function DashboardPage() {
  return (
    <div className="space-y-6">
      <h1 className="text-xl font-extrabold">داشبورد</h1>

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        {STAT_CARDS.map((card) => (
          <div
            key={card.label}
            className="rounded-lg border border-border bg-card p-4"
          >
            <div className="text-2xl">{card.icon}</div>
            <div className="mt-2 text-2xl font-extrabold">—</div>
            <div className="mt-1 text-xs font-semibold text-muted-foreground">{card.label}</div>
          </div>
        ))}
      </div>

      <p className="text-sm text-muted-foreground">
        آمار داشبورد پس از پیاده‌سازی فیچر درخواست قطعه و خرید فعال می‌شود.
      </p>
    </div>
  );
}
