/*
  Warnings:

  - The values [DELIVERED_TO_TECH] on the enum `PartRequestStatus` will be removed. If these variants are still used in the database, this will fail.
  - You are about to drop the column `receivedByTechAt` on the `part_requests` table. All the data in the column will be lost.

*/
-- AlterEnum
BEGIN;
CREATE TYPE "PartRequestStatus_new" AS ENUM ('CREATED', 'WAITING_CUSTOMER', 'APPROVED', 'REJECTED', 'WAITING_PURCHASE', 'PURCHASING', 'PURCHASED', 'NOT_FOUND', 'DELIVERED', 'RETURNED', 'CONSUMED', 'CLOSED', 'CANCELLED');
ALTER TABLE "part_requests" ALTER COLUMN "status" DROP DEFAULT;
ALTER TABLE "part_requests" ALTER COLUMN "status" TYPE "PartRequestStatus_new" USING ("status"::text::"PartRequestStatus_new");
ALTER TABLE "status_histories" ALTER COLUMN "previousStatus" TYPE "PartRequestStatus_new" USING ("previousStatus"::text::"PartRequestStatus_new");
ALTER TABLE "status_histories" ALTER COLUMN "newStatus" TYPE "PartRequestStatus_new" USING ("newStatus"::text::"PartRequestStatus_new");
ALTER TYPE "PartRequestStatus" RENAME TO "PartRequestStatus_old";
ALTER TYPE "PartRequestStatus_new" RENAME TO "PartRequestStatus";
DROP TYPE "PartRequestStatus_old";
ALTER TABLE "part_requests" ALTER COLUMN "status" SET DEFAULT 'CREATED';
COMMIT;

-- AlterTable
ALTER TABLE "part_requests" DROP COLUMN "receivedByTechAt";
