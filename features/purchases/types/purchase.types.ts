export type VendorDto = {
  id: string;
  name: string;
  phone: string | null;
};

export type PurchaseDto = {
  id: string;
  price: number;
  description: string | null;
  purchasedAt: Date;
  isReturned: boolean;
  returnReason: string | null;
  vendor: VendorDto;
  buyerName: string;
  partRequestId: string;
  partName: string;
  receptionNumber: string;
  requestStatus: string;
};
