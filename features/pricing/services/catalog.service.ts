import {
  listModels,
  listDeviceTypes,
  findDeviceTypeByName,
  createDeviceType,
  updateDeviceType,
  countModelsByDeviceType,
  deleteDeviceType,
  listBrands,
  findBrandByName,
  createBrand,
  updateBrand,
  countModelsByBrand,
  deleteBrand,
  findModelByIdRaw,
  findModelByName,
  createModel,
  updateModelName,
  countModelUsage,
  deleteModelHard,
  findDeviceTypeById,
  listAllParts,
  findPartByName,
  createPart,
  updatePartName,
  countPartUsage,
  softDeletePart,
} from '../repositories/taxonomy.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { ConflictError, NotFoundError } from '@/shared/lib/errors';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

async function log(context: ActorContext, action: string, entityType: string, entityId: string, value: object) {
  await logActivity({
    userId: context.actorId,
    action,
    entityType,
    entityId,
    newValue: value,
    ip: context.ip,
    device: context.device,
  });
}

// نمای کامل کاتالوگ برای صفحه‌ی مدیریت
export async function getCatalogService() {
  const [deviceTypes, brands, models, parts] = await Promise.all([
    listDeviceTypes(),
    listBrands(),
    listModels(),
    listAllParts(),
  ]);

  return {
    deviceTypes: deviceTypes.map((t) => ({ id: t.id, name: t.name })),
    brands: brands.map((b) => ({ id: b.id, name: b.name })),
    models,
    parts: parts.map((p) => ({ id: p.id, name: p.name })),
  };
}

// ----- DeviceType -----
export async function createDeviceTypeService(name: string, context: ActorContext) {
  if (await findDeviceTypeByName(name)) throw new ConflictError('این نوع دستگاه قبلاً ثبت شده است');
  const record = await createDeviceType(name);
  await log(context, 'CREATE_DEVICE_TYPE', 'DeviceType', record.id, { name });
  return record;
}

export async function updateDeviceTypeService(id: string, name: string, context: ActorContext) {
  const duplicate = await findDeviceTypeByName(name);
  if (duplicate && duplicate.id !== id) throw new ConflictError('این نوع دستگاه قبلاً ثبت شده است');
  const record = await updateDeviceType(id, name);
  await log(context, 'EDIT_DEVICE_TYPE', 'DeviceType', id, { name });
  return record;
}

export async function deleteDeviceTypeService(id: string, context: ActorContext) {
  const count = await countModelsByDeviceType(id);
  if (count > 0) throw new ConflictError(`این نوع دستگاه ${count} مدل دارد و قابل حذف نیست`);
  await deleteDeviceType(id);
  await log(context, 'DELETE_DEVICE_TYPE', 'DeviceType', id, {});
}

// ----- Brand -----
export async function createBrandService(name: string, context: ActorContext) {
  if (await findBrandByName(name)) throw new ConflictError('این برند قبلاً ثبت شده است');
  const record = await createBrand(name);
  await log(context, 'CREATE_BRAND', 'Brand', record.id, { name }); // از اکشن عمومی استفاده می‌شود
  return record;
}

export async function updateBrandService(id: string, name: string, context: ActorContext) {
  const duplicate = await findBrandByName(name);
  if (duplicate && duplicate.id !== id) throw new ConflictError('این برند قبلاً ثبت شده است');
  const record = await updateBrand(id, name);
  await log(context, 'EDIT_BRAND', 'Brand', id, { name });
  return record;
}

export async function deleteBrandService(id: string, context: ActorContext) {
  const count = await countModelsByBrand(id);
  if (count > 0) throw new ConflictError(`این برند ${count} مدل دارد و قابل حذف نیست`);
  await deleteBrand(id);
  await log(context, 'DELETE_BRAND', 'Brand', id, {});
}

// ----- Model -----
export async function createModelInCatalogService(
  input: { name: string; brandId: string; deviceTypeId: string },
  context: ActorContext,
) {
  const deviceType = await findDeviceTypeById(input.deviceTypeId);
  if (!deviceType) throw new NotFoundError('نوع دستگاه یافت نشد');
  const existing = await findModelByName(input.brandId, input.name);
  if (existing) throw new ConflictError('این مدل برای این برند قبلاً ثبت شده است');

  const model = await createModel(input);
  await log(context, 'CREATE_MODEL', 'DeviceModel', model.id, {
    name: model.name,
    brand: model.brand.name,
    deviceType: deviceType.name,
  });
  return { id: model.id, name: model.name, brandId: model.brandId, deviceTypeId: model.deviceTypeId };
}

export async function updateModelService(id: string, name: string, context: ActorContext) {
  const model = await findModelByIdRaw(id);
  if (!model) throw new NotFoundError('مدل یافت نشد');
  const duplicate = await findModelByName(model.brandId, name);
  if (duplicate && duplicate.id !== id) throw new ConflictError('این مدل برای این برند قبلاً ثبت شده است');
  const record = await updateModelName(id, name);
  await log(context, 'EDIT_MODEL', 'DeviceModel', id, { name });
  return record;
}

export async function deleteModelService(id: string, context: ActorContext) {
  const { prices, requests } = await countModelUsage(id);
  if (prices > 0 || requests > 0) {
    throw new ConflictError(
      `این مدل ${prices} قیمت و ${requests} درخواست دارد و قابل حذف نیست`,
    );
  }
  await deleteModelHard(id);
  await log(context, 'DELETE_MODEL', 'DeviceModel', id, {});
}

// ----- Part -----
export async function createPartService(name: string, context: ActorContext) {
  if (await findPartByName(name)) throw new ConflictError('این قطعه قبلاً ثبت شده است');
  const record = await createPart(name);
  await log(context, 'CREATE_PART', 'Part', record.id, { name });
  return record;
}

export async function updatePartService(id: string, name: string, context: ActorContext) {
  const duplicate = await findPartByName(name);
  if (duplicate && duplicate.id !== id) throw new ConflictError('این قطعه قبلاً ثبت شده است');
  const record = await updatePartName(id, name);
  await log(context, 'EDIT_PART', 'Part', id, { name });
  return record;
}

export async function deletePartService(id: string, context: ActorContext) {
  const { prices, requests } = await countPartUsage(id);
  if (prices > 0 || requests > 0) {
    throw new ConflictError(`این قطعه ${prices} قیمت و ${requests} درخواست دارد و قابل حذف نیست`);
  }
  await softDeletePart(id);
  await log(context, 'DELETE_PART', 'Part', id, {});
}
