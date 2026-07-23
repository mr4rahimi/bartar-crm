import type { TicketWithRelations } from '../repositories/ticket.repository';
import type { TicketDto, CustomerDto } from '../types/ticket.types';

export function toCustomerDto(customer: TicketWithRelations['customer']): CustomerDto {
  return {
    id: customer.id,
    title: customer.title,
    name: customer.name,
    phone: customer.phone,
    secondaryPhone: customer.secondaryPhone,
    nationalCode: customer.nationalCode,
    postalCode: customer.postalCode,
    address: customer.address,
  };
}

export function toTicketDto(ticket: TicketWithRelations): TicketDto {
  return {
    id: ticket.id,
    ticketNumber: ticket.ticketNumber,
    status: ticket.status,
    publicToken: ticket.publicToken,
    customer: toCustomerDto(ticket.customer),
    device: {
      deviceTypeId: ticket.device.model.deviceTypeId,
      deviceType: ticket.device.model.deviceType?.name ?? null,
      brandId: ticket.device.brandId,
      brand: ticket.device.brand.name,
      modelId: ticket.device.modelId,
      model: ticket.device.model.name,
      serial: ticket.device.serial,
    },
    devicePassword: ticket.devicePassword,
    estimatedCost: ticket.estimatedCost,
    estimatedDeliveryAt: ticket.estimatedDeliveryAt,
    accessories: ticket.accessories.map((item) => item.accessory.name),
    accessoryIds: ticket.accessories.map((item) => item.accessoryId),
    issues: ticket.issues.map((item) => item.issue.name),
    issueIds: ticket.issues.map((item) => item.issueId),
    technicianNotes: ticket.technicianNotes,
    customerNotes: ticket.customerNotes,
    issueDescription: ticket.issueDescription,
    shelfNumber: ticket.shelfNumber,
    createdByName: ticket.createdBy.name,
    assignedToId: ticket.assignedToId,
    assignedToName: ticket.assignedTo?.name ?? null,
    acceptedAt: ticket.acceptedAt,
    unrepairableReason: ticket.unrepairableReason,
    deliveredToCustomerAt: ticket.deliveredToCustomerAt,
    createdAt: ticket.createdAt,
    deletedAt: ticket.deletedAt,
    deletedByName: null,
  };
}
