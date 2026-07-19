-- CreateEnum
CREATE TYPE "NotificationChannel" AS ENUM ('IN_APP', 'SMS');

-- CreateEnum
CREATE TYPE "NotificationStatus" AS ENUM ('SENT', 'FAILED', 'SKIPPED');

-- AlterTable
ALTER TABLE "notifications" ADD COLUMN     "channel" "NotificationChannel" NOT NULL DEFAULT 'IN_APP',
ADD COLUMN     "entityId" TEXT,
ADD COLUMN     "entityType" TEXT,
ADD COLUMN     "error" TEXT,
ADD COLUMN     "patternCode" TEXT,
ADD COLUMN     "providerRef" TEXT,
ADD COLUMN     "recipient" TEXT,
ADD COLUMN     "status" "NotificationStatus" NOT NULL DEFAULT 'SENT';

-- AlterTable
ALTER TABLE "users" ADD COLUMN     "smsEnabled" BOOLEAN NOT NULL DEFAULT true;

-- CreateIndex
CREATE INDEX "notifications_entityType_entityId_idx" ON "notifications"("entityType", "entityId");
