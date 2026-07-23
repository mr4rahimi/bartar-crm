import type { CustomerTitle, RepairTicketStatus } from '@prisma/client';

export type CustomerDto = {
  id: string;
  title: CustomerTitle;
  name: string;
  phone: string;
  secondaryPhone: string | null;
  nationalCode: string | null;
  postalCode: string | null;
  address: string | null;
};

export type TicketDto = {
  id: string;
  ticketNumber: string;
  status: RepairTicketStatus;
  publicToken: string;
  customer: CustomerDto;
  device: {
    deviceTypeId: string | null;
    deviceType: string | null;
    brandId: string;
    brand: string;
    modelId: string;
    model: string;
    serial: string | null;
  };
  devicePassword: string | null;
  estimatedCost: number | null;
  estimatedDeliveryAt: Date | null;
  accessories: string[];
  accessoryIds: string[];
  issues: string[];
  issueIds: string[];
  technicianNotes: string | null;
  customerNotes: string | null;
  issueDescription: string | null;
  shelfNumber: string | null;
  assignedToId: string | null;
  assignedToName: string | null;
  acceptedAt: Date | null;
  unrepairableReason: string | null;
  deliveredToCustomerAt: Date | null;
  createdByName: string;
  createdAt: Date;
  deletedAt: Date | null;
  deletedByName: string | null;
};
