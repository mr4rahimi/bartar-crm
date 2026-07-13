import type {
  RepairTicket,
  Customer,
  Device,
  Brand,
  DeviceModel,
  User,
} from '@prisma/client';
import type { TicketDto } from '../types/ticket.types';

export type TicketWithRelations = RepairTicket & {
  customer: Customer;
  device: Device & { brand: Brand; model: DeviceModel };
  createdBy: User;
};

export function toTicketDto(ticket: TicketWithRelations): TicketDto {
  return {
    id: ticket.id,
    ticketNumber: ticket.ticketNumber,
    status: ticket.status,
    issueDescription: ticket.issueDescription,
    customer: {
      id: ticket.customer.id,
      name: ticket.customer.name,
      phone: ticket.customer.phone,
    },
    device: {
      brand: ticket.device.brand.name,
      model: ticket.device.model.name,
      serial: ticket.device.serial,
    },
    createdByName: ticket.createdBy.name,
    createdAt: ticket.createdAt,
  };
}
