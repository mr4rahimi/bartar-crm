import { z } from 'zod';
import { PART_REQUEST_ACTIONS } from '../constants/state-machine.constants';
import { positiveIntField } from '@/shared/validators/number.schema';

export const partRequestActionSchema = z.object({
  action: z.enum(PART_REQUEST_ACTIONS),
  price: positiveIntField('قیمت معتبر نیست').optional(),
  description: z.string().trim().optional(),
});

export type PartRequestActionInput = z.infer<typeof partRequestActionSchema>;
