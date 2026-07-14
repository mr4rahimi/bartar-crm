import { prisma } from '@/shared/lib/prisma';

export async function listDeviceTypes() {
  return prisma.deviceType.findMany({ orderBy: { name: 'asc' } });
}

export async function listBrands() {
  return prisma.brand.findMany({ orderBy: { name: 'asc' } });
}

export async function listModels() {
  return prisma.deviceModel.findMany({
    orderBy: { name: 'asc' },
    select: { id: true, name: true, brandId: true, deviceTypeId: true },
  });
}

export async function findModelById(modelId: string) {
  return prisma.deviceModel.findUnique({
    where: { id: modelId },
    include: { brand: true, deviceType: true },
  });
}

export async function findModelByName(brandId: string, name: string) {
  return prisma.deviceModel.findUnique({
    where: { brandId_name: { brandId, name } },
  });
}

export async function upsertBrand(name: string) {
  return prisma.brand.upsert({ where: { name }, update: {}, create: { name } });
}

export async function createModel(data: {
  name: string;
  brandId: string;
  deviceTypeId: string;
}) {
  return prisma.deviceModel.create({ data, include: { brand: true, deviceType: true } });
}

export async function findDeviceTypeById(deviceTypeId: string) {
  return prisma.deviceType.findUnique({ where: { id: deviceTypeId } });
}
