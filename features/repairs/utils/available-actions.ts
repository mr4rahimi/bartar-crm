import type { RepairTicketStatus } from '@prisma/client';
import { TICKET_ACTIONS, type TicketActionDef } from '../constants/workflow.constants';

export function getAvailableActions(
  status: RepairTicketStatus,
  assignedToId: string | null,
  actorId: string,
  permissions: string[],
): TicketActionDef[] {
  return TICKET_ACTIONS.filter((def) => {
    if (!def.from.includes(status)) return false;
    const isAssignee = assignedToId === actorId;
    const hasPermission = def.permission ? permissions.includes(def.permission) : false;

    if (def.assigneeOnly && def.permission) return isAssignee || hasPermission;
    if (def.assigneeOnly) return isAssignee;
    if (def.permission) return hasPermission;
    return true;
  });
}
