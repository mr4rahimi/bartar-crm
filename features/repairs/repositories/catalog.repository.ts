import { prisma } from '@/shared/lib/prisma';

export async function listBrandsWithModels() {
  return prisma.brand.findMany({
    include: { models: { orderBy: { name: 'asc' } } },
    orderBy: { name: 'asc' },
  });
}

// برند/مدل اگر وجود نداشته باشند ساخته می‌شوند (ورود آزاد در فرم پذیرش)
export async function upsertBrandAndModel(brandName: string, modelName: string) {
  const brand = await prisma.brand.upsert({
    where: { name: brandName },
    update: {},
    create: { name: brandName },
  });

  const model = await prisma.deviceModel.upsert({
    where: { brandId_name: { brandId: brand.id, name: modelName } },
    update: {},
    create: { brandId: brand.id, name: modelName },
  });

  return { brand, model };
}

export async function createDevice(data: {
  brandId: string;
  modelId: string;
  serial: string | null;
}) {
  return prisma.device.create({ data });
}
