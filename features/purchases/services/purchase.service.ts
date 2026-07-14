import {
  listPurchases,
  findPurchaseById,
  createPurchase,
  markPurchaseReturned,
} from '../repositories/purchase.repository';
import {
  listVendors,
  findVendorById,
  createVendor,
} from '../repositories/vendor.repository';
import {
  getPartRequestService,
  markPartRequestPurchased,
  markPartRequestReturned,
} from '@/features/part-requests/services/part-request.service';
import {
  applyPurchasePricing,
  type AutoPricingResult,
} from '@/features/pricing/services/pricing.service';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { AppError, NotFoundError } from '@/shared/lib/errors';
import type { RegisterPurchaseInput } from '../validators/register-purchase.schema';
import type { PurchaseDto, VendorDto } from '../types/purchase.types';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

type PurchaseWithRelations = Awaited<ReturnType<typeof createPurchase>>;

function toPurchaseDto(purchase: PurchaseWithRelations): PurchaseDto {
  return {
    id: purchase.id,
    price: purchase.price,
    description: purchase.description,
    purchasedAt: purchase.purchasedAt,
    isReturned: purchase.isReturned,
    returnReason: purchase.returnReason,
    vendor: {
      id: purchase.vendor.id,
      name: purchase.vendor.name,
      phone: purchase.vendor.phone,
    },
    buyerName: purchase.buyer.name,
    partRequestId: purchase.partRequestId,
    partName: purchase.partRequest.part.name,
    receptionNumber: purchase.partRequest.receptionNumber,
    requestStatus: purchase.partRequest.status,
  };
}

export async function listVendorsService(): Promise<VendorDto[]> {
  const vendors = await listVendors();
  return vendors.map((vendor) => ({ id: vendor.id, name: vendor.name, phone: vendor.phone }));
}

export async function createVendorService(
  input: { name: string; phone?: string | null },
  context: ActorContext,
) {
  const vendor = await createVendor({ name: input.name, phone: input.phone ?? null });

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_VENDOR',
    entityType: 'Vendor',
    entityId: vendor.id,
    newValue: { name: vendor.name },
    ip: context.ip,
    device: context.device,
  });

  return { id: vendor.id, name: vendor.name, phone: vendor.phone };
}

export async function listPurchasesService(page: number) {
  const pageSize = 20;
  const { items, total } = await listPurchases({ page, pageSize });
  return { items: items.map(toPurchaseDto), total, page, pageSize };
}

export async function registerPurchaseService(
  input: RegisterPurchaseInput,
  context: ActorContext,
): Promise<{ purchase: PurchaseDto; pricing: AutoPricingResult }> {
  // درخواست + وضعیت مجاز (اعتبارسنجی کامل در markPartRequestPurchased)
  const request = await getPartRequestService(input.partRequestId);

  // فروشنده: موجود یا ساخت سریع — Vendor Rules: خرید بدون Vendor ممنوع
  let vendorId: string;
  if (input.vendorId) {
    const vendor = await findVendorById(input.vendorId);
    if (!vendor) throw new NotFoundError('فروشنده یافت نشد');
    vendorId = vendor.id;
  } else {
    const vendor = await createVendorService(input.newVendor!, context);
    vendorId = vendor.id;
  }

  const purchase = await createPurchase({
    partRequestId: input.partRequestId,
    vendorId,
    price: input.price,
    description: input.description || null,
    buyerId: context.actorId,
  });

  // گذار وضعیت (State Machine در فیچر part-requests)
  await markPartRequestPurchased(
    input.partRequestId,
    context,
    `خرید از ${purchase.vendor.name} — ${input.price.toLocaleString('fa-IR')} تومان`,
  );

  // Auto-Pricing — docs/15-pricing-integration.md
  const requestDetail = await getPartRequestService(input.partRequestId);
  const pricing = await applyPurchasePricing({
    partId: purchase.partRequest.partId,
    modelId: purchase.partRequest.modelId,
    quality: requestDetail.quality,
    buyPrice: input.price,
    purchaseId: purchase.id,
    context,
  });

  await logActivity({
    userId: context.actorId,
    action: 'REGISTER_PURCHASE',
    entityType: 'Purchase',
    entityId: purchase.id,
    newValue: {
      partRequestId: input.partRequestId,
      receptionNumber: request.receptionNumber,
      vendorId,
      price: input.price,
      announcedPrice: request.announcedPrice,
    },
    ip: context.ip,
    device: context.device,
  });

  return { purchase: toPurchaseDto(purchase), pricing };
}

export async function returnPurchaseService(
  purchaseId: string,
  reason: string,
  context: ActorContext,
) {
  const purchase = await findPurchaseById(purchaseId);
  if (!purchase) throw new NotFoundError('خرید یافت نشد');
  if (purchase.isReturned) throw new AppError('این خرید قبلاً مرجوع شده است', 409);

  const updated = await markPurchaseReturned(purchaseId, reason);

  await markPartRequestReturned(purchase.partRequestId, context, `مرجوعی: ${reason}`);

  await logActivity({
    userId: context.actorId,
    action: 'RETURN_PURCHASE',
    entityType: 'Purchase',
    entityId: purchaseId,
    previousValue: { isReturned: false },
    newValue: { isReturned: true, reason },
    ip: context.ip,
    device: context.device,
  });

  return toPurchaseDto(updated);
}
