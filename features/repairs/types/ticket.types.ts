import type { RepairTicketStatus } from '@prisma/client';

export type TicketDto = {
  id: string;
  ticketNumber: string;
  status: RepairTicketStatus;
  issueDescription: string | null;
  customer: { id: string; name: string; phone: string };
  device: { brand: string; model: string; serial: string | null };
  createdByName: string;
  createdAt: Date;
};

export type CustomerDto = {
  id: string;
  name: string;
  phone: string;
};
