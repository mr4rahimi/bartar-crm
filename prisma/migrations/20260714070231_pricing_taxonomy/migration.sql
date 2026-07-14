-- AlterTable
ALTER TABLE "device_models" ADD COLUMN     "deviceTypeId" TEXT;

-- AlterTable
ALTER TABLE "part_requests" ADD COLUMN     "modelId" TEXT;

-- AlterTable
ALTER TABLE "price_histories" ADD COLUMN     "modelId" TEXT,
ADD COLUMN     "quality" "PartQuality";

-- CreateTable
CREATE TABLE "device_types" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "device_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "part_prices" (
    "id" TEXT NOT NULL,
    "modelId" TEXT NOT NULL,
    "partId" TEXT NOT NULL,
    "quality" "PartQuality" NOT NULL,
    "buyPrice" INTEGER,
    "sellPrice" INTEGER,
    "needsReview" BOOLEAN NOT NULL DEFAULT false,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "part_prices_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "device_types_name_key" ON "device_types"("name");

-- CreateIndex
CREATE UNIQUE INDEX "part_prices_modelId_partId_quality_key" ON "part_prices"("modelId", "partId", "quality");

-- AddForeignKey
ALTER TABLE "device_models" ADD CONSTRAINT "device_models_deviceTypeId_fkey" FOREIGN KEY ("deviceTypeId") REFERENCES "device_types"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "part_requests" ADD CONSTRAINT "part_requests_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "device_models"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "price_histories" ADD CONSTRAINT "price_histories_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "device_models"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "part_prices" ADD CONSTRAINT "part_prices_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES "device_models"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "part_prices" ADD CONSTRAINT "part_prices_partId_fkey" FOREIGN KEY ("partId") REFERENCES "parts"("id") ON DELETE RESTRICT ON UPDATE CASCADE;
