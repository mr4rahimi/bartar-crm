-- AlterEnum
ALTER TYPE "PartRequestStatus" ADD VALUE 'DELIVERED_TO_TECH';

-- AlterTable
ALTER TABLE "part_requests" ADD COLUMN     "receivedByTechAt" TIMESTAMP(3);

-- CreateTable
CREATE TABLE "repair_notes" (
    "id" TEXT NOT NULL,
    "ticketId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "repair_notes_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "repair_notes_ticketId_idx" ON "repair_notes"("ticketId");

-- AddForeignKey
ALTER TABLE "repair_notes" ADD CONSTRAINT "repair_notes_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "repair_tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "repair_notes" ADD CONSTRAINT "repair_notes_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
