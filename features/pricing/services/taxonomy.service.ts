import {
  listDeviceTypes,
  listBrands,
  listModels,
  findModelById,
  findModelByName,
  upsertBrand,
  createModel,
  findDeviceTypeById,
} from '../repositories/taxonomy.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { NotFoundError, ConflictError } from '@/shared/lib/errors';
import type { CreateModelInput } from '../validators/create-model.schema';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

/** لیست‌های تخت — انتخاب آبشاری سمت کلاینت فیلتر می‌شود */
export async function getTaxonomyService() {
  const [deviceTypes, brands, models] = await Promise.all([
    listDeviceTypes(),
    listBrands(),
    listModels(),
  ]);

  return {
    deviceTypes: deviceTypes.map((type) => ({ id: type.id, name: type.name })),
    brands: brands.map((brand) => ({ id: brand.id, name: brand.name })),
    models,
  };
}

/** استفاده‌ی سایر فیچرها (part-requests) — ارتباط بین فیچرها فقط از طریق Service */
export async function getModelForLinking(modelId: string) {
  const model = await findModelById(modelId);
  if (!model) throw new NotFoundError('مدل انتخاب‌شده یافت نشد');

  return {
    id: model.id,
    name: model.name,
    brandName: model.brand.name,
    deviceTypeName: model.deviceType?.name ?? null,
  };
}

/** ساخت مدل جدید در لحظه (از فرم درخواست قطعه یا مدیریت قیمت‌ها) */
export async function createModelService(input: CreateModelInput, context: ActorContext) {
  const deviceType = await findDeviceTypeById(input.deviceTypeId);
  if (!deviceType) throw new NotFoundError('نوع دستگاه یافت نشد');

  const brand = input.brandId
    ? { id: input.brandId }
    : await upsertBrand(input.brandName!.trim());

  const existing = await findModelByName(brand.id, input.name);
  if (existing) throw new ConflictError('این مدل برای این برند قبلاً ثبت شده است');

  const model = await createModel({
    name: input.name,
    brandId: brand.id,
    deviceTypeId: input.deviceTypeId,
  });

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_MODEL',
    entityType: 'DeviceModel',
    entityId: model.id,
    newValue: { name: model.name, brand: model.brand.name, deviceType: deviceType.name },
    ip: context.ip,
    device: context.device,
  });

  return {
    id: model.id,
    name: model.name,
    brandId: model.brandId,
    deviceTypeId: model.deviceTypeId,
  };
}
