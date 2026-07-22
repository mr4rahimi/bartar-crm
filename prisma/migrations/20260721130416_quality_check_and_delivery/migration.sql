-- AlterEnum
-- This migration adds more than one value to an enum.
-- With PostgreSQL versions 11 and earlier, this is not possible
-- in a single migration. This can be worked around by creating
-- multiple migrations, each migration adding only one value to
-- the enum.


ALTER TYPE "RepairTicketStatus" ADD VALUE 'QUALITY_CHECK';
ALTER TYPE "RepairTicketStatus" ADD VALUE 'READY_FOR_DELIVERY';
ALTER TYPE "RepairTicketStatus" ADD VALUE 'UNREPAIRABLE';
ALTER TYPE "RepairTicketStatus" ADD VALUE 'DELIVERED_TO_CUSTOMER';

-- AlterTable
ALTER TABLE "repair_tickets" ADD COLUMN     "customerNotifiedAt" TIMESTAMP(3),
ADD COLUMN     "deliveredToCustomerAt" TIMESTAMP(3),
ADD COLUMN     "qualityCheckById" TEXT,
ADD COLUMN     "receivedByReceptionAt" TIMESTAMP(3),
ADD COLUMN     "unrepairableReason" TEXT;

-- CreateTable
CREATE TABLE "quality_checks" (
    "id" TEXT NOT NULL,
    "ticketId" TEXT NOT NULL,
    "checkedById" TEXT NOT NULL,
    "notes" TEXT NOT NULL,
    "passed" BOOLEAN NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "quality_checks_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "quality_checks_ticketId_idx" ON "quality_checks"("ticketId");

-- AddForeignKey
ALTER TABLE "quality_checks" ADD CONSTRAINT "quality_checks_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "repair_tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "quality_checks" ADD CONSTRAINT "quality_checks_checkedById_fkey" FOREIGN KEY ("checkedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
