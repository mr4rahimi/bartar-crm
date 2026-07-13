import { prisma } from '@/shared/lib/prisma';

export async function searchCustomers(search: string, take = 8) {
  return prisma.customer.findMany({
    where: {
      deletedAt: null,
      OR: [
        { name: { contains: search, mode: 'insensitive' } },
        { phone: { contains: search } },
      ],
    },
    orderBy: { createdAt: 'desc' },
    take,
  });
}

export async function findCustomerById(customerId: string) {
  return prisma.customer.findFirst({ where: { id: customerId, deletedAt: null } });
}

export async function createCustomer(data: { name: string; phone: string }) {
  return prisma.customer.create({ data });
}
