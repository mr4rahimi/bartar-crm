import { searchCustomers } from '../repositories/customer.repository';
import type { CustomerDto } from '../types/ticket.types';

export async function searchCustomersService(search: string): Promise<CustomerDto[]> {
  if (search.trim().length < 2) return [];

  const customers = await searchCustomers(search.trim());
  return customers.map((customer) => ({
    id: customer.id,
    name: customer.name,
    phone: customer.phone,
  }));
}
