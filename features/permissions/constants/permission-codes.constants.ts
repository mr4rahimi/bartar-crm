// منبع واحد کدهای Permission — دقیقاً طبق docs/06-user-roles.md

export const PERMISSIONS = {
  // Authentication
  LOGIN: { code: 'LOGIN', group: 'Authentication' },
  LOGOUT: { code: 'LOGOUT', group: 'Authentication' },

  // Repair
  CREATE_REPAIR: { code: 'CREATE_REPAIR', group: 'Repair' },
  EDIT_REPAIR: { code: 'EDIT_REPAIR', group: 'Repair' },
  VIEW_REPAIR: { code: 'VIEW_REPAIR', group: 'Repair' },
  DELETE_REPAIR: { code: 'DELETE_REPAIR', group: 'Repair' },

  // Part Request
  CREATE_PART_REQUEST: { code: 'CREATE_PART_REQUEST', group: 'Part Request' },
  EDIT_PART_REQUEST: { code: 'EDIT_PART_REQUEST', group: 'Part Request' },
  DELETE_PART_REQUEST: { code: 'DELETE_PART_REQUEST', group: 'Part Request' },
  VIEW_PART_REQUEST: { code: 'VIEW_PART_REQUEST', group: 'Part Request' },
  CHANGE_STATUS: { code: 'CHANGE_STATUS', group: 'Part Request' },

  // Purchase
  START_PURCHASE: { code: 'START_PURCHASE', group: 'Purchase' },
  REGISTER_PURCHASE: { code: 'REGISTER_PURCHASE', group: 'Purchase' },
  EDIT_PURCHASE: { code: 'EDIT_PURCHASE', group: 'Purchase' },
  RETURN_PURCHASE: { code: 'RETURN_PURCHASE', group: 'Purchase' },
  NOT_FOUND: { code: 'NOT_FOUND', group: 'Purchase' },

  // Pricing
  VIEW_PRICE: { code: 'VIEW_PRICE', group: 'Pricing' },
  EDIT_PRICE: { code: 'EDIT_PRICE', group: 'Pricing' },
  VIEW_PRICE_HISTORY: { code: 'VIEW_PRICE_HISTORY', group: 'Pricing' },

  // Vendor
  CREATE_VENDOR: { code: 'CREATE_VENDOR', group: 'Vendor' },
  EDIT_VENDOR: { code: 'EDIT_VENDOR', group: 'Vendor' },
  DELETE_VENDOR: { code: 'DELETE_VENDOR', group: 'Vendor' },
  VIEW_VENDOR: { code: 'VIEW_VENDOR', group: 'Vendor' },

  // Users
  CREATE_USER: { code: 'CREATE_USER', group: 'Users' },
  EDIT_USER: { code: 'EDIT_USER', group: 'Users' },
  DELETE_USER: { code: 'DELETE_USER', group: 'Users' },
  VIEW_USER: { code: 'VIEW_USER', group: 'Users' },

  // Roles
  CREATE_ROLE: { code: 'CREATE_ROLE', group: 'Roles' },
  EDIT_ROLE: { code: 'EDIT_ROLE', group: 'Roles' },
  DELETE_ROLE: { code: 'DELETE_ROLE', group: 'Roles' },
  ASSIGN_ROLE: { code: 'ASSIGN_ROLE', group: 'Roles' },

  // Permission
  ASSIGN_PERMISSION: { code: 'ASSIGN_PERMISSION', group: 'Permission' },

  // Logs
  VIEW_ACTIVITY_LOG: { code: 'VIEW_ACTIVITY_LOG', group: 'Logs' },
  VIEW_SYSTEM_LOG: { code: 'VIEW_SYSTEM_LOG', group: 'Logs' },

  // Reports
  VIEW_REPORTS: { code: 'VIEW_REPORTS', group: 'Reports' },
  EXPORT_REPORTS: { code: 'EXPORT_REPORTS', group: 'Reports' },

  // Settings
  VIEW_SETTINGS: { code: 'VIEW_SETTINGS', group: 'Settings' },
  EDIT_SETTINGS: { code: 'EDIT_SETTINGS', group: 'Settings' },
} as const;

export const ALL_PERMISSION_CODES = Object.values(PERMISSIONS).map((p) => p.code);
