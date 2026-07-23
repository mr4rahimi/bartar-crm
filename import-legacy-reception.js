#!/usr/bin/env node
/**
 * ایمپورت پذیرش‌های قدیمی به Bartar CRM جدید
 * -------------------------------------------------------------
 * فقط CREATE / UPSERT انجام می‌دهد؛ هیچ رکورد موجودی را UPDATE یا DELETE نمی‌کند.
 * Idempotent است: اگر دوباره اجرا شود، پذیرش‌هایی که ticketNumber شان
 * از قبل در دیتابیس هست، رد می‌شوند (دوباره ساخته نمی‌شوند).
 *
 * نحوه اجرا:
 *   node import-legacy-reception.js            -> فقط گزارش (dry-run) بدون هیچ نوشتنی
 *   node import-legacy-reception.js --commit   -> نوشتن واقعی در دیتابیسی که DATABASE_URL
 *                                                  در .env همین پروژه به آن اشاره می‌کند
 *
 * پیش‌نیاز: import_payload.json باید کنار همین فایل باشد.
 * پیش‌نیاز: قبل از --commit روی سرور، حتماً از دیتابیس pg_dump بگیر.
 */
const { PrismaClient } = require('@prisma/client');
const fs = require('fs');
const path = require('path');

const prisma = new PrismaClient();

const ADMIN_USER_ID = process.env.IMPORT_CREATED_BY_ID || 'cmrizjjwb0019gmio8se0jmba'; // مدیر سیستم
const COMMIT = process.argv.includes('--commit');
const PAYLOAD_PATH = path.join(__dirname, 'import_payload.json');

function maskDbUrl(url) {
  if (!url) return '(تنظیم نشده)';
  try {
    const u = new URL(url);
    return `${u.protocol}//${u.username}:***@${u.hostname}:${u.port}${u.pathname}`;
  } catch {
    return '(قابل خواندن نیست)';
  }
}

async function main() {
  if (!fs.existsSync(PAYLOAD_PATH)) {
    console.error(`فایل import_payload.json کنار اسکریپت پیدا نشد: ${PAYLOAD_PATH}`);
    process.exit(1);
  }
  const records = JSON.parse(fs.readFileSync(PAYLOAD_PATH, 'utf-8'));

  console.log('=========================================================');
  console.log(` هدف اتصال (DATABASE_URL): ${maskDbUrl(process.env.DATABASE_URL)}`);
  console.log(` حالت اجرا: ${COMMIT ? 'COMMIT — نوشتن واقعی در دیتابیس' : 'DRY-RUN — فقط گزارش، هیچ چیز نوشته نمی‌شود'}`);
  console.log(` تعداد رکورد ورودی: ${records.length}`);
  console.log('=========================================================');

  const adminUser = await prisma.user.findUnique({ where: { id: ADMIN_USER_ID } });
  if (!adminUser) {
    console.error(`کاربر ادمین با id=${ADMIN_USER_ID} در این دیتابیس پیدا نشد. عملیات متوقف شد.`);
    process.exit(1);
  }
  console.log(`createdById => ${adminUser.name} (${adminUser.phone})\n`);

  const brandCache = new Map();
  const deviceTypeCache = new Map();
  const modelCache = new Map();
  const customerCache = new Map();

  let willCreateTickets = 0;
  let skippedExisting = 0;
  let newBrands = new Set(), existingBrandsSeen = new Set();
  let newDeviceTypes = new Set(), existingDeviceTypesSeen = new Set();
  let newModels = new Set(), existingModelsSeen = new Set();
  let newCustomers = 0, matchedCustomers = 0;
  const errors = [];

  for (const rec of records) {
    try {
      const existingTicket = await prisma.repairTicket.findUnique({ where: { ticketNumber: rec.ticketNumber } });
      if (existingTicket) {
        skippedExisting++;
        continue;
      }

      if (!COMMIT) {
        // فقط بررسی، بدون نوشتن — برای گزارش دقیق‌تر از قبل/جدید بودن brand/model/type
        let brand = brandCache.get(rec.brandName);
        if (brand === undefined) {
          brand = await prisma.brand.findUnique({ where: { name: rec.brandName } });
          brandCache.set(rec.brandName, brand || null);
        }
        brand ? existingBrandsSeen.add(rec.brandName) : newBrands.add(rec.brandName);

        let deviceType = deviceTypeCache.get(rec.deviceTypeName);
        if (deviceType === undefined) {
          deviceType = await prisma.deviceType.findUnique({ where: { name: rec.deviceTypeName } });
          deviceTypeCache.set(rec.deviceTypeName, deviceType || null);
        }
        deviceType ? existingDeviceTypesSeen.add(rec.deviceTypeName) : newDeviceTypes.add(rec.deviceTypeName);

        if (brand) {
          const modelKey = `${brand.id}|${rec.modelName}`;
          let model = modelCache.get(modelKey);
          if (model === undefined) {
            model = await prisma.deviceModel.findUnique({ where: { brandId_name: { brandId: brand.id, name: rec.modelName } } });
            modelCache.set(modelKey, model || null);
          }
          model ? existingModelsSeen.add(modelKey) : newModels.add(`${rec.brandName} / ${rec.modelName}`);
        } else {
          newModels.add(`${rec.brandName} / ${rec.modelName}`);
        }

        let customer = customerCache.get(rec.customerPhone);
        if (customer === undefined) {
          customer = await prisma.customer.findFirst({ where: { phone: rec.customerPhone } });
          customerCache.set(rec.customerPhone, customer || null);
        }
        customer ? matchedCustomers++ : newCustomers++;

        willCreateTickets++;
        continue;
      }

      // ---------- COMMIT mode: نوشتن واقعی ----------
      await prisma.$transaction(async (tx) => {
        let brand = brandCache.get(rec.brandName);
        if (!brand) {
          brand = await tx.brand.upsert({
            where: { name: rec.brandName },
            update: {},
            create: { name: rec.brandName },
          });
          brandCache.set(rec.brandName, brand);
        }

        let deviceType = deviceTypeCache.get(rec.deviceTypeName);
        if (!deviceType) {
          deviceType = await tx.deviceType.upsert({
            where: { name: rec.deviceTypeName },
            update: {},
            create: { name: rec.deviceTypeName },
          });
          deviceTypeCache.set(rec.deviceTypeName, deviceType);
        }

        const modelKey = `${brand.id}|${rec.modelName}`;
        let model = modelCache.get(modelKey);
        if (!model) {
          model = await tx.deviceModel.upsert({
            where: { brandId_name: { brandId: brand.id, name: rec.modelName } },
            update: {},
            create: { name: rec.modelName, brandId: brand.id, deviceTypeId: deviceType.id },
          });
          modelCache.set(modelKey, model);
        }

        let customer = customerCache.get(rec.customerPhone);
        if (!customer) {
          customer = await tx.customer.findFirst({ where: { phone: rec.customerPhone } });
          if (!customer) {
            customer = await tx.customer.create({
              data: { name: rec.customerName, phone: rec.customerPhone },
            });
          }
          customerCache.set(rec.customerPhone, customer);
        }

        const device = await tx.device.create({
          data: {
            brandId: brand.id,
            modelId: model.id,
            serial: rec.serial || null,
          },
        });

        await tx.repairTicket.create({
          data: {
            ticketNumber: rec.ticketNumber,
            customerId: customer.id,
            deviceId: device.id,
            status: rec.status,
            shelfNumber: rec.shelfNumber,
            estimatedDeliveryAt: rec.estimatedDeliveryAt ? new Date(rec.estimatedDeliveryAt) : null,
            technicianNotes: rec.technicianNotes,
            customerNotes: rec.customerNotes,
            createdById: adminUser.id,
            createdAt: rec.createdAt ? new Date(rec.createdAt) : undefined,
          },
        });
      });

      willCreateTickets++;
      if (willCreateTickets % 500 === 0) console.log(`... ${willCreateTickets} پذیرش پردازش شد`);
    } catch (err) {
      errors.push({ ticketNumber: rec.ticketNumber, error: String((err && err.message) || err) });
    }
  }

  console.log('\n=========================================================');
  console.log('نتیجه نهایی:');
  console.log(`  پذیرش‌های ${COMMIT ? 'ایجادشده' : 'قابل‌ایجاد'}: ${willCreateTickets}`);
  console.log(`  از قبل موجود بود (رد شد، دست نخورد): ${skippedExisting}`);
  console.log(`  خطا: ${errors.length}`);
  if (!COMMIT) {
    console.log(`  برند جدید: ${newBrands.size}  |  برند موجود: ${existingBrandsSeen.size}`);
    console.log(`  نوع دستگاه جدید: ${newDeviceTypes.size}  |  نوع دستگاه موجود: ${existingDeviceTypesSeen.size}`);
    console.log(`  مدل جدید: ${newModels.size}  |  مدل موجود: ${existingModelsSeen.size}`);
    console.log(`  مشتری جدید: ${newCustomers}  |  مشتری تطبیق‌یافته (تکراری نشد): ${matchedCustomers}`);
    if (newBrands.size) console.log(`  برندهای جدید: ${[...newBrands].join(', ')}`);
  }
  if (errors.length) {
    fs.writeFileSync(path.join(__dirname, 'import_errors.json'), JSON.stringify(errors, null, 2));
    console.log('  جزئیات خطاها در import_errors.json ذخیره شد');
  }
  console.log('=========================================================');
}

main()
  .catch((e) => {
    console.error('خطای غیرمنتظره:', e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
