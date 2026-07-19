import type { PartRequest, Part, User, StatusHistory } from '@prisma/client';
import type { PartRequestDto, PartRequestDetailDto } from '../types/part-request.types';

export type PartRequestWithRelations = PartRequest & {
  part: Part;
  createdBy: User;
};

export type PartRequestWithHistory = PartRequestWithRelations & {
  statusHistory: (StatusHistory & { changedBy: User })[];
};

export function toPartRequestDto(request: PartRequestWithRelations): PartRequestDto {
  return {
    id: request.id,
    receptionNumber: request.receptionNumber,
    partId: request.partId,
    modelId: request.modelId,
    partName: request.part.name,
    quality: request.quality,
    quantity: request.quantity,
    brand: request.brand,
    model: request.model,
    status: request.status,
    announcedPrice: request.announcedPrice,
    depositAmount: request.depositAmount,
    isTest: request.isTest,
    description: request.description,
    createdByName: request.createdBy.name,
    createdAt: request.createdAt,
  };
}

export function toPartRequestDetailDto(request: PartRequestWithHistory): PartRequestDetailDto {
  return {
    ...toPartRequestDto(request),
    history: request.statusHistory.map((entry) => ({
      id: entry.id,
      previousStatus: entry.previousStatus,
      newStatus: entry.newStatus,
      changedByName: entry.changedBy.name,
      description: entry.description,
      createdAt: entry.createdAt,
    })),
  };
}
