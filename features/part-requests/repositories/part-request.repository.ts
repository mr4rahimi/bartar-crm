import { prisma } from '@/shared/lib/prisma';
import type { PartQuality, PartRequestStatus, Prisma } from '@prisma/client';

const listInclude = { part: true, createdBy: true } as const;

const detailInclude = {
  part: true,
  createdBy: true,
  statusHistory: {
    include: { changedBy: true },
    orderBy: { createdAt: 'desc' as const },
  },
} as const;

export type ListPartRequestsParams = {
  page: number;
  pageSize: number;
  search?: string;
  status?: PartRequestStatus;
};

export async function listPartRequests({ page, pageSize, search, status }: ListPartRequestsParams) {
  const where: Prisma.PartRequestWhereInput = {
    deletedAt: null,
    ...(status && { status }),
    ...(search && {
      OR: [
        { receptionNumber: { contains: search } },
        { part: { name: { contains: search, mode: 'insensitive' } } },
      ],
    }),
  };

  const [items, total] = await prisma.$transaction([
    prisma.partRequest.findMany({
      where,
      include: listInclude,
      orderBy: { createdAt: 'desc' },
      skip: (page - 1) * pageSize,
      take: pageSize,
    }),
    prisma.partRequest.count({ where }),
  ]);

  return { items, total };
}

export async function findPartRequestById(requestId: string) {
  return prisma.partRequest.findFirst({
    where: { id: requestId, deletedAt: null },
    include: detailInclude,
  });
}

export type CreatePartRequestData = {
  receptionNumber: string;
  partId: string;
  modelId: string | null;
  quality: PartQuality;
  quantity: number;
  brand: string | null;
  model: string | null;
  announcedPrice: number | null;
  isTest: boolean;
  description: string | null;
  createdById: string;
  repairTicketId: string | null;
};

export async function createPartRequest(data: CreatePartRequestData) {
  return prisma.partRequest.create({ data, include: detailInclude });
}

/** تغییر وضعیت + ثبت StatusHistory در یک تراکنش — Audit Rules در 05-workflows.md */
export async function transitionPartRequest(params: {
  requestId: string;
  previousStatus: PartRequestStatus;
  newStatus: PartRequestStatus;
  changedById: string;
  description: string | null;
  announcedPrice?: number;
}) {
  const { requestId, previousStatus, newStatus, changedById, description, announcedPrice } = params;

  await prisma.$transaction([
    prisma.partRequest.update({
      where: { id: requestId },
      data: { status: newStatus, ...(announcedPrice !== undefined && { announcedPrice }) },
    }),
    prisma.statusHistory.create({
      data: { partRequestId: requestId, previousStatus, newStatus, changedById, description },
    }),
  ]);
}

export type UpdatePartRequestData = {
  receptionNumber?: string;
  partId?: string;
  modelId?: string | null;
  quality?: PartQuality;
  quantity?: number;
  brand?: string | null;
  model?: string | null;
  announcedPrice?: number | null;
  depositAmount?: number;
  isTest?: boolean;
  description?: string | null;
};

export async function updatePartRequest(requestId: string, data: UpdatePartRequestData) {
  return prisma.partRequest.update({ where: { id: requestId }, data });
}

/** درخواست‌های قطعه‌ی متصل به یک قبض پذیرش (docs/22) */
export async function listPartRequestsByTicket(repairTicketId: string) {
  return prisma.partRequest.findMany({
    where: { repairTicketId, deletedAt: null },
    include: detailInclude,
    orderBy: { createdAt: 'desc' },
  });
}
