/**
 * Import داده از دیتابیس price-next (فایل pg_dump plain SQL)
 * اجرا: npx tsx scripts/import-price-next.ts price-db/price_db_plain_YYYYMMDD.sql
 * ایمپورت create-only است؛ اجرای مجدد امن است. — docs/15-pricing-integration.md
 */
import { readFileSync } from 'fs';
import { PrismaClient, PartQuality } from '@prisma/client';

const prisma = new PrismaClient();

function parseCopyBlock(sql: string, table: string): (string | null)[][] {
  const marker = `COPY public."${table}"`;
  const start = sql.indexOf(marker);
  if (start === -1) throw new Error(`جدول ${table} در فایل یافت نشد`);
  const headerEnd = sql.indexOf('FROM stdin;', start) + 'FROM stdin;'.length;
  const end = sql.indexOf('\n\\.', headerEnd);
  const body = sql.slice(headerEnd, end).trim();
  if (!body) return [];
  return body
    .split('\n')
    .map((line) => line.split('\t').map((value) => (value === '\\N' ? null : value)));
}

async function main() {
  const filePath = process.argv[2];
  if (!filePath) {
    console.error('مسیر فایل SQL را بدهید: npx tsx scripts/import-price-next.ts <file.sql>');
    process.exit(1);
  }

  const sql = readFileSync(filePath, 'utf8');

  // ۱) DeviceTypes
  const deviceTypeMap = new Map<string, string>();
  for (const [oldId, name] of parseCopyBlock(sql, 'DeviceType')) {
    const record = await prisma.deviceType.upsert({
      where: { name: name! },
      update: {},
      create: { name: name! },
    });
    deviceTypeMap.set(oldId!, record.id);
  }
  console.log(`✓ ${deviceTypeMap.size} نوع دستگاه`);

  // ۲) Brands
  const brandMap = new Map<string, string>();
  for (const [oldId, name] of parseCopyBlock(sql, 'Brand')) {
    const record = await prisma.brand.upsert({
      where: { name: name! },
      update: {},
      create: { name: name! },
    });
    brandMap.set(oldId!, record.id);
  }
  console.log(`✓ ${brandMap.size} برند`);

  // ۳) Models — یکتایی CRM: [brandId, name]؛ تداخل نام با پسوند نوع دستگاه حل می‌شود
  const deviceTypeNames = new Map(parseCopyBlock(sql, 'DeviceType').map((r) => [r[0]!, r[1]!]));
  const modelMap = new Map<string, string>();
  let modelsCreated = 0;
  let modelsRenamed = 0;

  for (const [oldId, name, oldBrandId, oldDeviceTypeId] of parseCopyBlock(sql, 'Model')) {
    const brandId = brandMap.get(oldBrandId!)!;
    const deviceTypeId = deviceTypeMap.get(oldDeviceTypeId!)!;

    const existing = await prisma.deviceModel.findUnique({
      where: { brandId_name: { brandId, name: name! } },
    });

    if (existing) {
      if (existing.deviceTypeId === null) {
        await prisma.deviceModel.update({ where: { id: existing.id }, data: { deviceTypeId } });
        modelMap.set(oldId!, existing.id);
      } else if (existing.deviceTypeId === deviceTypeId) {
        modelMap.set(oldId!, existing.id);
      } else {
        // همان نام زیر همان برند ولی نوع دستگاه متفاوت → پسوند
        const suffixedName = `${name} (${deviceTypeNames.get(oldDeviceTypeId!)})`;
        const renamed = await prisma.deviceModel.upsert({
          where: { brandId_name: { brandId, name: suffixedName } },
          update: {},
          create: { name: suffixedName, brandId, deviceTypeId },
        });
        modelMap.set(oldId!, renamed.id);
        modelsRenamed++;
      }
    } else {
      const created = await prisma.deviceModel.create({
        data: { name: name!, brandId, deviceTypeId },
      });
      modelMap.set(oldId!, created.id);
      modelsCreated++;
    }
  }
  console.log(`✓ ${modelMap.size} مدل (${modelsCreated} جدید، ${modelsRenamed} با پسوند نوع دستگاه)`);

  // ۴) PartCategories → Part
  const partMap = new Map<string, string>();
  for (const [oldId, name] of parseCopyBlock(sql, 'PartCategory')) {
    const record = await prisma.part.upsert({
      where: { name: name! },
      update: {},
      create: { name: name! },
    });
    partMap.set(oldId!, record.id);
  }
  console.log(`✓ ${partMap.size} دسته قطعه`);

  // ۵) Prices → PartPrice (فقط فروش، create-only) + PriceHistory پایه
  const QUALITY_COLUMNS: [number, PartQuality][] = [
    [5, 'ORIGINAL'], // originalPrice
    [4, 'HIGH_COPY'], // copy1Price
    [3, 'COPY'], // copy2Price
  ];

  let pricesCreated = 0;
  let pricesSkipped = 0;

  for (const row of parseCopyBlock(sql, 'Price')) {
    const modelId = modelMap.get(row[1]!);
    const partId = partMap.get(row[2]!);
    if (!modelId || !partId) continue;

    const notes = row[6];
    const updatedAt = new Date(row[7]!);

    for (const [columnIndex, quality] of QUALITY_COLUMNS) {
      const raw = row[columnIndex];
      if (raw == null) continue; // null یا undefined
      const sellPrice = parseInt(raw, 10);
      if (Number.isNaN(sellPrice) || sellPrice <= 0) continue;

      const existing = await prisma.partPrice.findUnique({
        where: { modelId_partId_quality: { modelId, partId, quality } },
      });
      if (existing) {
        pricesSkipped++;
        continue;
      }

      await prisma.partPrice.create({
        data: { modelId, partId, quality, sellPrice, buyPrice: null, needsReview: false, notes },
      });
      await prisma.priceHistory.create({
        data: { partId, modelId, quality, type: 'SELL', price: sellPrice, recordedAt: updatedAt },
      });
      pricesCreated++;
    }
  }
  console.log(`✓ ${pricesCreated} قیمت فروش ایمپورت شد (${pricesSkipped} از قبل موجود، رد شد)`);
  console.log('🎉 Import کامل شد');
}

main()
  .catch((error) => { console.error(error); process.exit(1); })
  .finally(() => prisma.$disconnect());
