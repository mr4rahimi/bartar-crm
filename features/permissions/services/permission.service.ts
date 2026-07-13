import { listPermissions } from '../repositories/permission.repository';

export async function listPermissionsService() {
  const permissions = await listPermissions();

  return permissions.map((permission) => ({
    id: permission.id,
    code: permission.code,
    group: permission.group,
    description: permission.description,
  }));
}
