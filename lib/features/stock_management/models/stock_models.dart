class StockAuditRecord {
  final String id;
  final String date;
  final String type;
  final String auditor;
  final String status;
  final int discrepancies;

  const StockAuditRecord({
    required this.id,
    required this.date,
    required this.type,
    required this.auditor,
    required this.status,
    required this.discrepancies,
  });
}

class StockTransferRecord {
  final String id;
  final String date;
  final String fromLocation;
  final String toLocation;
  final int quantity;
  final String status;

  const StockTransferRecord({
    required this.id,
    required this.date,
    required this.fromLocation,
    required this.toLocation,
    required this.quantity,
    required this.status,
  });
}

class BranchTransferRecord {
  final String id;
  final String date;
  final String sourceBranch;
  final String destinationBranch;
  final int quantity;
  final String status;

  const BranchTransferRecord({
    required this.id,
    required this.date,
    required this.sourceBranch,
    required this.destinationBranch,
    required this.quantity,
    required this.status,
  });
}

class StockReturnRecord {
  final String id;
  final String date;
  final String vendor;
  final String item;
  final int quantity;
  final String reason;
  final String status;

  const StockReturnRecord({
    required this.id,
    required this.date,
    required this.vendor,
    required this.item,
    required this.quantity,
    required this.reason,
    required this.status,
  });
}

class InternalConsumptionRecord {
  final String id;
  final String date;
  final String department;
  final String item;
  final int quantity;
  final String purpose;
  final String user;

  const InternalConsumptionRecord({
    required this.id,
    required this.date,
    required this.department,
    required this.item,
    required this.quantity,
    required this.purpose,
    required this.user,
  });
}

class InventoryAudit {
  final String date;
  final String type;
  final String status;
  final int discrepancies;

  const InventoryAudit({
    required this.date,
    required this.type,
    required this.status,
    required this.discrepancies,
  });
}

class InventoryAdjustment {
  final String date;
  final String reason;
  final String status;
  final String quantity;

  const InventoryAdjustment({
    required this.date,
    required this.reason,
    required this.status,
    required this.quantity,
  });
}

