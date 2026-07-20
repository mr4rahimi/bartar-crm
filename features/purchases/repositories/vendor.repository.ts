import { prisma } from '@/shared/lib/prisma';

export async function listVendors() {
  return prisma.vendor.findMany({
    where: { deletedAt: null, isActive: true },
    orderBy: { name: 'asc' },
  });
}

export async function findVendorById(vendorId: string) {
  return prisma.vendor.findFirst({ where: { id: vendorId, deletedAt: null } });
}

export async function createVendor(data: {
  name: string;
  phone: string | null;
  landline: string | null;
}) {
  return prisma.vendor.create({ data });
}
