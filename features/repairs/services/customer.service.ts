import {
  searchCustomers,
  findCustomerById,
  findCustomerByPhone,
  createCustomer,
} from '../repositories/customer.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { ConflictError } from '@/shared/lib/errors';
import { toCustomerDto } from '../utils/ticket.mapper';
import type { CustomerInput } from '../validators/customer.schema';
import type { CustomerDto } from '../types/ticket.types';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

/** نام نمایشی از اجزا ساخته می‌شود (docs/20-reception-spec.md) */
export function buildDisplayName(input: CustomerInput): string {
  if (input.title === 'COMPANY') return input.companyName!.trim();
  return `${input.firstName} ${input.lastName}`.trim();
}

export async function searchCustomersService(term: string): Promise<CustomerDto[]> {
  const customers = await searchCustomers(term);
  return customers.map(toCustomerDto);
}

export async function createCustomerService(
  input: CustomerInput,
  context: ActorContext,
): Promise<CustomerDto> {
  const duplicate = await findCustomerByPhone(input.phone);
  if (duplicate) throw new ConflictError('مشتری با این شماره موبایل قبلاً ثبت شده است');

  const customer = await createCustomer({
    title: input.title,
    name: buildDisplayName(input),
    firstName: input.firstName || null,
    lastName: input.lastName || null,
    companyName: input.companyName || null,
    nationalCode: input.nationalCode || null,
    postalCode: input.postalCode || null,
    phone: input.phone,
    secondaryPhone: input.secondaryPhone || null,
    address: input.address || null,
  });

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_CUSTOMER',
    entityType: 'Customer',
    entityId: customer.id,
    newValue: { name: customer.name, phone: customer.phone },
    ip: context.ip,
    device: context.device,
  });

  return toCustomerDto(customer);
}

export async function getCustomerService(customerId: string) {
  return findCustomerById(customerId);
}