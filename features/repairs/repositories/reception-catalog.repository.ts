import { prisma } from '@/shared/lib/prisma';

/** موارد مخصوص نوع دستگاه + موارد عمومی (deviceTypeId = null) */
export async function listAccessories(deviceTypeId?: string) {
  return prisma.accessory.findMany({
    where: {
      deletedAt: null,
      ...(deviceTypeId && { OR: [{ deviceTypeId }, { deviceTypeId: null }] }),
    },
    orderBy: { name: 'asc' },
  });
}

export async function listIssues(deviceTypeId?: string) {
  return prisma.deviceIssue.findMany({
    where: {
      deletedAt: null,
      ...(deviceTypeId && { OR: [{ deviceTypeId }, { deviceTypeId: null }] }),
    },
    orderBy: { name: 'asc' },
  });
}

export async function createAccessory(name: string, deviceTypeId: string | null) {
  return prisma.accessory.create({ data: { name, deviceTypeId } });
}

export async function createIssue(name: string, deviceTypeId: string | null) {
  return prisma.deviceIssue.create({ data: { name, deviceTypeId } });
}

export async function findAccessoryByName(name: string, deviceTypeId: string | null) {
  return prisma.accessory.findFirst({ where: { name, deviceTypeId } });
}

export async function findIssueByName(name: string, deviceTypeId: string | null) {
  return prisma.deviceIssue.findFirst({ where: { name, deviceTypeId } });
}
