import { z } from 'zod';

// طبق docs/08-api-conventions.md: page / pageSize / search
export const paginationSchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  pageSize: z.coerce.number().int().min(1).max(100).default(20),
  search: z.string().trim().min(1).optional(),
});

export type PaginationInput = z.infer<typeof paginationSchema>;
