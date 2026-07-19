/**
 * تولید CHANGELOG.md از shared/constants/changelog.ts و هم‌سان‌سازی نسخه در package.json
 * اجرا: npm run changelog
 */
import { writeFileSync, readFileSync } from 'fs';
import { CHANGELOG, CHANGE_TYPE_LABELS, APP_VERSION } from '../shared/constants/changelog';

const header = `# Changelog

قالب: [Keep a Changelog](https://keepachangelog.com/fa/1.1.0/) — نسخه‌گذاری: [SemVer](https://semver.org/lang/fa/)

> این فایل به‌صورت خودکار از \`shared/constants/changelog.ts\` تولید می‌شود. مستقیم ویرایشش نکن.
`;

const body = CHANGELOG.map((release) => {
  const grouped = new Map<string, string[]>();
  for (const change of release.changes) {
    const label = CHANGE_TYPE_LABELS[change.type];
    grouped.set(label, [...(grouped.get(label) ?? []), change.text]);
  }

  const sections = [...grouped.entries()]
    .map(([label, items]) => `### ${label}\n${items.map((item) => `- ${item}`).join('\n')}`)
    .join('\n\n');

  return `## [${release.version}] — ${release.date}\n**${release.title}**\n\n${sections}`;
}).join('\n\n---\n\n');

writeFileSync('CHANGELOG.md', `${header}\n${body}\n`);

const pkgPath = 'package.json';
const pkg = JSON.parse(readFileSync(pkgPath, 'utf8'));
pkg.version = APP_VERSION;
writeFileSync(pkgPath, `${JSON.stringify(pkg, null, 2)}\n`);

console.log(`✓ CHANGELOG.md ساخته شد و package.json روی ${APP_VERSION} تنظیم شد`);
