-- AlterEnum
ALTER TYPE "RepairTicketStatus" ADD VALUE 'ASSIGNED';

-- AlterTable
ALTER TABLE "repair_tickets" ADD COLUMN     "acceptedAt" TIMESTAMP(3),
ADD COLUMN     "assignedAt" TIMESTAMP(3),
ADD COLUMN     "assignedById" TEXT,
ADD COLUMN     "assignedToId" TEXT;

-- CreateTable
CREATE TABLE "ticket_status_histories" (
    "id" TEXT NOT NULL,
    "ticketId" TEXT NOT NULL,
    "previousStatus" "RepairTicketStatus",
    "newStatus" "RepairTicketStatus" NOT NULL,
    "action" TEXT NOT NULL,
    "changedById" TEXT NOT NULL,
    "assignedToId" TEXT,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ticket_status_histories_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "ticket_status_histories_ticketId_idx" ON "ticket_status_histories"("ticketId");

-- AddForeignKey
ALTER TABLE "repair_tickets" ADD CONSTRAINT "repair_tickets_assignedToId_fkey" FOREIGN KEY ("assignedToId") REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_status_histories" ADD CONSTRAINT "ticket_status_histories_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "repair_tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ticket_status_histories" ADD CONSTRAINT "ticket_status_histories_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
