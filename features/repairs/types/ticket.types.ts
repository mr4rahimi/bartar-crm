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
  device: { deviceType: string | null; brand: string; model: string; serial: string | null };
  devicePassword: string | null;
  estimatedCost: number | null;
  estimatedDeliveryAt: Date | null;
  accessories: string[];
  issues: string[];
  technicianNotes: string | null;
  customerNotes: string | null;
  issueDescription: string | null;
  shelfNumber: string | null;
  createdByName: string;
  createdAt: Date;
};
