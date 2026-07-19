import { prisma } from '@/shared/lib/prisma';
import type { CustomerTitle } from '@prisma/client';

export async function searchCustomers(term: string) {
  return prisma.customer.findMany({
    where: {
      deletedAt: null,
      OR: [
        { name: { contains: term, mode: 'insensitive' } },
        { phone: { contains: term } },
        { secondaryPhone: { contains: term } },
      ],
    },
    orderBy: { createdAt: 'desc' },
    take: 10,
  });
}

export async function findCustomerById(customerId: string) {
  return prisma.customer.findFirst({ where: { id: customerId, deletedAt: null } });
}

export async function findCustomerByPhone(phone: string) {
  return prisma.customer.findFirst({ where: { phone, deletedAt: null } });
}

export type CreateCustomerData = {
  title: CustomerTitle;
  name: string;
  firstName: string | null;
  lastName: string | null;
  companyName: string | null;
  nationalCode: string | null;
  postalCode: string | null;
  phone: string;
  secondaryPhone: string | null;
  address: string | null;
};

export async function createCustomer(data: CreateCustomerData) {
  return prisma.customer.create({ data });
}
