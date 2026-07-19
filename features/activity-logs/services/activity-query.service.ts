import { listEntityLogs } from '../repositories/activity-query.repository';

export type EntityLogDto = {
  id: string;
  action: string;
  userName: string;
  previousValue: unknown;
  newValue: unknown;
  createdAt: Date;
};

export async function getEntityLogsService(
  entityType: string,
  entityId: string,
): Promise<EntityLogDto[]> {
  const logs = await listEntityLogs(entityType, entityId);

  return logs.map((log) => ({
    id: log.id,
    action: log.action,
    userName: log.user.name,
    previousValue: log.previousValue,
    newValue: log.newValue,
    createdAt: log.createdAt,
  }));
}
