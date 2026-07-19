import {
  listPartRequests,
  findPartRequestById,
  createPartRequest,
  transitionPartRequest,
} from '../repositories/part-request.repository';
import { findPartById, listParts } from '../repositories/part.repository';
import { findActionDef } from '../constants/state-machine.constants';
import { PART_REQUEST_STATUS_LABELS } from '@/shared/constants/part-request-status';
import { getModelForLinking } from '@/features/pricing/services/taxonomy.service';
import { notifyPartRequestEventAsync } from '@/features/notifications/services/notification.service';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { AppError, NotFoundError } from '@/shared/lib/errors';
import { toPartRequestDto, toPartRequestDetailDto } from '../utils/part-request.mapper';
import type { CreatePartRequestInput } from '../validators/create-part-request.schema';
import type { PartRequestQueryInput } from '../validators/part-request-query.schema';
import type { PartRequestActionInput } from '../validators/part-request-action.schema';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

export async function listPartRequestsService(query: PartRequestQueryInput) {
  const { items, total } = await listPartRequests({
    page: query.page,
    pageSize: query.pageSize,
    search: query.search,
    status: query.status,
  });

  return { items: items.map(toPartRequestDto), total, page: query.page, pageSize: query.pageSize };
}

export async function getPartRequestService(requestId: string) {
  const request = await findPartRequestById(requestId);
  if (!request) throw new NotFoundError('درخواست قطعه یافت نشد');
  return toPartRequestDetailDto(request);
}

export async function listPartOptionsService() {
  const parts = await listParts();
  return parts.map((part) => ({ id: part.id, name: part.name }));
}

export async function createPartRequestService(
  input: CreatePartRequestInput,
  context: ActorContext,
) {
  const part = await findPartById(input.partId);
  if (!part) throw new NotFoundError('قطعه انتخاب‌شده یافت نشد');

  // اتصال به تاکسونومی: نام برند/مدل برای نمایش از تاکسونومی denormalize می‌شود
  const linkedModel = input.modelId ? await getModelForLinking(input.modelId) : null;

  const request = await createPartRequest({
    receptionNumber: input.receptionNumber,
    partId: part.id,
    modelId: linkedModel?.id ?? null,
    quality: input.quality,
    quantity: input.quantity,
    brand: linkedModel?.brandName ?? input.brand ?? null,
    model: linkedModel?.name ?? input.model ?? null,
    announcedPrice: input.announcedPrice ?? null,
    isTest: input.isTest,
    description: input.description || null,
    createdById: context.actorId,
  });

  // Workflow 1 — ثبت اولین رکورد تاریخچه
  await transitionPartRequest({
    requestId: request.id,
    previousStatus: request.status,
    newStatus: 'CREATED',
    changedById: context.actorId,
    description: 'ثبت درخواست',
  });

  // اگر هنگام ثبت قیمت اعلامی داشت → مستقیم به انتظار تایید مشتری (Workflow 2)
  if (input.announcedPrice) {
    await transitionPartRequest({
      requestId: request.id,
      previousStatus: 'CREATED',
      newStatus: 'WAITING_CUSTOMER',
      changedById: context.actorId,
      description: 'اعلام هزینه هنگام ثبت',
    });
  }

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_PART_REQUEST',
    entityType: 'PartRequest',
    entityId: request.id,
    newValue: {
      receptionNumber: input.receptionNumber,
      part: part.name,
      quality: input.quality,
      quantity: input.quantity,
      announcedPrice: input.announcedPrice ?? null,
    },
    ip: context.ip,
    device: context.device,
  });

  const created = await getPartRequestService(request.id);

  notifyPartRequestEventAsync({
    requestId: created.id,
    status: created.status,
    receptionNumber: created.receptionNumber,
    partName: created.partName,
    modelName: created.model,
    announcedPrice: created.announcedPrice,
    createdById: context.actorId,
  });

  return created;
}

export async function applyPartRequestActionService(
  requestId: string,
  input: PartRequestActionInput,
  context: ActorContext,
) {
  const request = await findPartRequestById(requestId);
  if (!request) throw new NotFoundError('درخواست قطعه یافت نشد');

  const def = findActionDef(input.action);

  // اعتبارسنجی گذار طبق State Machine — گذار غیرمجاز 409
  if (!def.from.includes(request.status)) {
    throw new AppError(
      `از وضعیت «${PART_REQUEST_STATUS_LABELS[request.status]}» امکان «${def.label}» وجود ندارد`,
      409,
    );
  }

  if (def.requiresPrice && !input.price) {
    throw new AppError('قیمت اعلامی الزامی است', 400);
  }

  await transitionPartRequest({
    requestId,
    previousStatus: request.status,
    newStatus: def.to,
    changedById: context.actorId,
    description: input.description || def.label,
    ...(def.requiresPrice && { announcedPrice: input.price }),
  });

  // Workflow 3 — تایید مشتری خودکار وارد صف خرید می‌شود
  if (input.action === 'APPROVE') {
    await transitionPartRequest({
      requestId,
      previousStatus: 'APPROVED',
      newStatus: 'WAITING_PURCHASE',
      changedById: context.actorId,
      description: 'ورود خودکار به صف خرید',
    });
  }

  await logActivity({
    userId: context.actorId,
    action: 'CHANGE_STATUS',
    entityType: 'PartRequest',
    entityId: requestId,
    previousValue: { status: request.status },
    newValue: {
      status: input.action === 'APPROVE' ? 'WAITING_PURCHASE' : def.to,
      action: input.action,
      price: input.price ?? null,
    },
    ip: context.ip,
    device: context.device,
  });

  const updated = await getPartRequestService(requestId);

  notifyPartRequestEventAsync({
    requestId: updated.id,
    status: updated.status,
    receptionNumber: updated.receptionNumber,
    partName: updated.partName,
    modelName: updated.model,
    announcedPrice: updated.announcedPrice,
    createdById: request.createdById,
  });

  return updated;
}

// ----- گذارهای سیستمیِ خرید — فقط از طریق Service فیچر purchases فراخوانی می‌شوند -----

/** ثبت خرید موفق: WAITING_PURCHASE/PURCHASING → PURCHASED (Workflow 7) */
export async function markPartRequestPurchased(
  requestId: string,
  context: ActorContext,
  description: string,
) {
  const request = await findPartRequestById(requestId);
  if (!request) throw new NotFoundError('درخواست قطعه یافت نشد');

  if (request.status !== 'PURCHASING' && request.status !== 'WAITING_PURCHASE') {
    throw new AppError(
      `از وضعیت «${PART_REQUEST_STATUS_LABELS[request.status]}» امکان ثبت خرید وجود ندارد`,
      409,
    );
  }

  // گذار مستقیم از صف: اول PURCHASING ثبت می‌شود تا State Machine حفظ شود
  if (request.status === 'WAITING_PURCHASE') {
    await transitionPartRequest({
      requestId,
      previousStatus: 'WAITING_PURCHASE',
      newStatus: 'PURCHASING',
      changedById: context.actorId,
      description: 'شروع خرید (هنگام ثبت خرید)',
    });
  }

  await transitionPartRequest({
    requestId,
    previousStatus: 'PURCHASING',
    newStatus: 'PURCHASED',
    changedById: context.actorId,
    description,
  });

  notifyPartRequestEventAsync({
    requestId,
    status: 'PURCHASED',
    receptionNumber: request.receptionNumber,
    partName: request.part.name,
    modelName: request.model,
    announcedPrice: request.announcedPrice,
    createdById: request.createdById,
  });

  return request;
}

/** مرجوعی: PURCHASED/DELIVERED → RETURNED (Workflow 10) */
export async function markPartRequestReturned(
  requestId: string,
  context: ActorContext,
  description: string,
) {
  const request = await findPartRequestById(requestId);
  if (!request) throw new NotFoundError('درخواست قطعه یافت نشد');

  if (request.status !== 'PURCHASED' && request.status !== 'DELIVERED') {
    throw new AppError(
      `از وضعیت «${PART_REQUEST_STATUS_LABELS[request.status]}» امکان مرجوعی وجود ندارد`,
      409,
    );
  }

  await transitionPartRequest({
    requestId,
    previousStatus: request.status,
    newStatus: 'RETURNED',
    changedById: context.actorId,
    description,
  });

  notifyPartRequestEventAsync({
    requestId,
    status: 'RETURNED',
    receptionNumber: request.receptionNumber,
    partName: request.part.name,
    modelName: request.model,
    announcedPrice: request.announcedPrice,
    createdById: request.createdById,
  });

  return request;
}
