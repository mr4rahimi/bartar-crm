import {
  listAccessories,
  listIssues,
  createAccessory,
  createIssue,
  findAccessoryByName,
  findIssueByName,
} from '../repositories/reception-catalog.repository';
import { logActivity } from '@/features/activity-logs/services/log-activity.service';
import { ConflictError } from '@/shared/lib/errors';

type ActorContext = { actorId: string; ip?: string | null; device?: string | null };

export async function getReceptionCatalogService(deviceTypeId?: string) {
  const [accessories, issues] = await Promise.all([
    listAccessories(deviceTypeId),
    listIssues(deviceTypeId),
  ]);

  return {
    accessories: accessories.map((item) => ({ id: item.id, name: item.name })),
    issues: issues.map((item) => ({ id: item.id, name: item.name })),
  };
}

export async function createAccessoryService(
  input: { name: string; deviceTypeId?: string },
  context: ActorContext,
) {
  const deviceTypeId = input.deviceTypeId ?? null;
  if (await findAccessoryByName(input.name, deviceTypeId)) {
    throw new ConflictError('این متعلقات قبلاً ثبت شده است');
  }

  const accessory = await createAccessory(input.name, deviceTypeId);

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_ACCESSORY',
    entityType: 'Accessory',
    entityId: accessory.id,
    newValue: { name: accessory.name },
    ip: context.ip,
    device: context.device,
  });

  return { id: accessory.id, name: accessory.name };
}

export async function createIssueService(
  input: { name: string; deviceTypeId?: string },
  context: ActorContext,
) {
  const deviceTypeId = input.deviceTypeId ?? null;
  if (await findIssueByName(input.name, deviceTypeId)) {
    throw new ConflictError('این ایراد قبلاً ثبت شده است');
  }

  const issue = await createIssue(input.name, deviceTypeId);

  await logActivity({
    userId: context.actorId,
    action: 'CREATE_ISSUE',
    entityType: 'DeviceIssue',
    entityId: issue.id,
    newValue: { name: issue.name },
    ip: context.ip,
    device: context.device,
  });

  return { id: issue.id, name: issue.name };
}
