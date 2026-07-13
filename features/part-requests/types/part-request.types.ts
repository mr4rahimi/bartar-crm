import type { PartQuality, PartRequestStatus } from '@prisma/client';

export type StatusHistoryDto = {
  id: string;
  previousStatus: PartRequestStatus | null;
  newStatus: PartRequestStatus;
  changedByName: string;
  description: string | null;
  createdAt: Date;
};

export type PartRequestDto = {
  id: string;
  receptionNumber: string;
  partName: string;
  quality: PartQuality;
  quantity: number;
  brand: string | null;
  model: string | null;
  status: PartRequestStatus;
  announcedPrice: number | null;
  depositAmount: number;
  isTest: boolean;
  description: string | null;
  createdByName: string;
  createdAt: Date;
};

export type PartRequestDetailDto = PartRequestDto & {
  history: StatusHistoryDto[];
};
