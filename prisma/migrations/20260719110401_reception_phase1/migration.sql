/*
  Warnings:

  - A unique constraint covering the columns `[publicToken]` on the table `repair_tickets` will be added. If there are existing duplicate values, this will fail.
  - The required column `publicToken` was added to the `repair_tickets` table with a prisma-level default value. This is not possible if the table is not empty. Please add this column as optional, then populate it before making it required.

*/
-- CreateEnum
CREATE TYPE "CustomerTitle" AS ENUM ('MR', 'MRS', 'COMPANY');

-- AlterTable
ALTER TABLE "customers" ADD COLUMN     "companyName" TEXT,
ADD COLUMN     "firstName" TEXT,
ADD COLUMN     "lastName" TEXT,
ADD COLUMN     "nationalCode" TEXT,
ADD COLUMN     "postalCode" TEXT,
ADD COLUMN     "title" "CustomerTitle" NOT NULL DEFAULT 'MR';

-- AlterTable
ALTER TABLE "repair_tickets" ADD COLUMN     "customerNotes" TEXT,
ADD COLUMN     "devicePassword" TEXT,
ADD COLUMN     "estimatedCost" INTEGER,
ADD COLUMN     "estimatedDeliveryAt" TIMESTAMP(3),
ADD COLUMN     "publicToken" TEXT,
ADD COLUMN     "shelfNumber" TEXT,
ADD COLUMN     "technicianNotes" TEXT;

-- CreateTable
CREATE TABLE "accessories" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "deviceTypeId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "accessories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "device_issues" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "deviceTypeId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "device_issues_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "repair_ticket_accessories" (
    "ticketId" TEXT NOT NULL,
    "accessoryId" TEXT NOT NULL,

    CONSTRAINT "repair_ticket_accessories_pkey" PRIMARY KEY ("ticketId","accessoryId")
);

-- CreateTable
CREATE TABLE "repair_ticket_issues" (
    "ticketId" TEXT NOT NULL,
    "issueId" TEXT NOT NULL,

    CONSTRAINT "repair_ticket_issues_pkey" PRIMARY KEY ("ticketId","issueId")
);

-- CreateIndex
CREATE UNIQUE INDEX "accessories_name_deviceTypeId_key" ON "accessories"("name", "deviceTypeId");

-- CreateIndex
CREATE UNIQUE INDEX "device_issues_name_deviceTypeId_key" ON "device_issues"("name", "deviceTypeId");

-- CreateIndex
CREATE UNIQUE INDEX "repair_tickets_publicToken_key" ON "repair_tickets"("publicToken");

-- AddForeignKey
ALTER TABLE "accessories" ADD CONSTRAINT "accessories_deviceTypeId_fkey" FOREIGN KEY ("deviceTypeId") REFERENCES "device_types"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "device_issues" ADD CONSTRAINT "device_issues_deviceTypeId_fkey" FOREIGN KEY ("deviceTypeId") REFERENCES "device_types"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "repair_ticket_accessories" ADD CONSTRAINT "repair_ticket_accessories_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "repair_tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "repair_ticket_accessories" ADD CONSTRAINT "repair_ticket_accessories_accessoryId_fkey" FOREIGN KEY ("accessoryId") REFERENCES "accessories"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "repair_ticket_issues" ADD CONSTRAINT "repair_ticket_issues_ticketId_fkey" FOREIGN KEY ("ticketId") REFERENCES "repair_tickets"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "repair_ticket_issues" ADD CONSTRAINT "repair_ticket_issues_issueId_fkey" FOREIGN KEY ("issueId") REFERENCES "device_issues"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- Populate publicToken for existing rows, then enforce NOT NULL
UPDATE "repair_tickets" SET "publicToken" = md5(random()::text || clock_timestamp()::text || id) WHERE "publicToken" IS NULL;
ALTER TABLE "repair_tickets" ALTER COLUMN "publicToken" SET NOT NULL;
