/*
  Warnings:

  - Added the required column `receptionNumber` to the `part_requests` table without a default value. This is not possible if the table is not empty.

*/
-- DropForeignKey
ALTER TABLE "part_requests" DROP CONSTRAINT "part_requests_repairTicketId_fkey";

-- AlterTable
ALTER TABLE "part_requests" ADD COLUMN     "quantity" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "receptionNumber" TEXT NOT NULL,
ALTER COLUMN "repairTicketId" DROP NOT NULL;

-- AddForeignKey
ALTER TABLE "part_requests" ADD CONSTRAINT "part_requests_repairTicketId_fkey" FOREIGN KEY ("repairTicketId") REFERENCES "repair_tickets"("id") ON DELETE SET NULL ON UPDATE CASCADE;
