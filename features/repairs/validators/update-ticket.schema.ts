import { z } from 'zod';
import { positiveIntField } from '@/shared/validators/number.schema';

export const updateTicketSchema = z.object({
  customerId: z.string().min(1).optional(),
  brandId: z.string().min(1).optional(),
  modelId: z.string().min(1).optional(),
  serial: z.string().trim().nullable().optional(),
  devicePassword: z.string().trim().nullable().optional(),
  shelfNumber: z.string().trim().nullable().optional(),
  estimatedCost: positiveIntField('هزینه تقریبی معتبر نیست').nullable().optional(),
  estimatedDeliveryAt: z.string().datetime().nullable().optional(),
  status: z.enum(['OPEN', 'IN_PROGRESS', 'DELIVERED', 'CLOSED', 'CANCELLED']).optional(),
  accessoryIds: z.array(z.string()).optional(),
  issueIds: z.array(z.string()).optional(),
  technicianNotes: z.string().trim().nullable().optional(),
  customerNotes: z.string().trim().nullable().optional(),
});

export type UpdateTicketInput = z.infer<typeof updateTicketSchema>;
export type UpdateTicketFormInput = z.input<typeof updateTicketSchema>;
