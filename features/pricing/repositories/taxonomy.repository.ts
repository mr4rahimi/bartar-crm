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

// ----- مدیریت کامل کاتالوگ (CRUD) — مطابق price-next -----

export async function findDeviceTypeByName(name: string) {
  return prisma.deviceType.findUnique({ where: { name } });
}

export async function createDeviceType(name: string) {
  return prisma.deviceType.create({ data: { name } });
}

export async function updateDeviceType(id: string, name: string) {
  return prisma.deviceType.update({ where: { id }, data: { name } });
}

export async function countModelsByDeviceType(deviceTypeId: string) {
  return prisma.deviceModel.count({ where: { deviceTypeId } });
}

export async function deleteDeviceType(id: string) {
  return prisma.deviceType.delete({ where: { id } });
}

export async function findBrandByName(name: string) {
  return prisma.brand.findUnique({ where: { name } });
}

export async function createBrand(name: string) {
  return prisma.brand.create({ data: { name } });
}

export async function updateBrand(id: string, name: string) {
  return prisma.brand.update({ where: { id }, data: { name } });
}

export async function countModelsByBrand(brandId: string) {
  return prisma.deviceModel.count({ where: { brandId } });
}

export async function deleteBrand(id: string) {
  return prisma.brand.delete({ where: { id } });
}

export async function findModelByIdRaw(id: string) {
  return prisma.deviceModel.findUnique({ where: { id } });
}

export async function updateModelName(id: string, name: string) {
  return prisma.deviceModel.update({ where: { id }, data: { name } });
}

export async function countModelUsage(modelId: string) {
  const [prices, requests] = await Promise.all([
    prisma.partPrice.count({ where: { modelId } }),
    prisma.partRequest.count({ where: { modelId, deletedAt: null } }),
  ]);
  return { prices, requests };
}

export async function deleteModelHard(id: string) {
  return prisma.deviceModel.delete({ where: { id } });
}

export async function listAllParts() {
  return prisma.part.findMany({ where: { deletedAt: null }, orderBy: { name: 'asc' } });
}

export async function findPartByName(name: string) {
  return prisma.part.findUnique({ where: { name } });
}

export async function createPart(name: string) {
  return prisma.part.create({ data: { name } });
}

export async function updatePartName(id: string, name: string) {
  return prisma.part.update({ where: { id }, data: { name } });
}

export async function countPartUsage(partId: string) {
  const [prices, requests] = await Promise.all([
    prisma.partPrice.count({ where: { partId } }),
    prisma.partRequest.count({ where: { partId, deletedAt: null } }),
  ]);
  return { prices, requests };
}

export async function softDeletePart(id: string) {
  return prisma.part.update({ where: { id }, data: { deletedAt: new Date() } });
}
