class PaymentCardItem {
  final int id;
  final String maskedCard;
  final String last4;
  final String cardHolder;
  final String brand;
  final String status;

  PaymentCardItem({
    required this.id,
    required this.maskedCard,
    required this.last4,
    required this.cardHolder,
    required this.brand,
    required this.status,
  });

  factory PaymentCardItem.fromJson(Map<String, dynamic> json) {
    return PaymentCardItem(
      id: (json['id'] ?? 0) as int,
      maskedCard: (json['maskedCard'] ?? '').toString(),
      last4: (json['last4'] ?? '').toString(),
      cardHolder: (json['cardHolder'] ?? '').toString(),
      brand: (json['brand'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
    );
  }
}

class ServiceContractItem {
  final int id;
  final String subject;
  final String status;
  final String startDate;
  final String dueDate;
  final double usedUnits;
  final double totalUnits;

  ServiceContractItem({
    required this.id,
    required this.subject,
    required this.status,
    required this.startDate,
    required this.dueDate,
    required this.usedUnits,
    required this.totalUnits,
  });

  factory ServiceContractItem.fromJson(Map<String, dynamic> json) {
    return ServiceContractItem(
      id: (json['id'] ?? 0) as int,
      subject: (json['subject'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      dueDate: (json['due_date'] ?? '').toString(),
      usedUnits: (json['used_units'] ?? 0).toDouble(),
      totalUnits: (json['total_units'] ?? 0).toDouble(),
    );
  }
}

class InvoiceItem {
  final int id;
  final String number;
  final String subject;
  final String status;
  final double total;
  final String createdTime;

  InvoiceItem({
    required this.id,
    required this.number,
    required this.subject,
    required this.status,
    required this.total,
    required this.createdTime,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: (json['id'] ?? 0) as int,
      number: (json['number'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      total: (json['total'] ?? 0).toDouble(),
      createdTime: (json['createdtime'] ?? '').toString(),
    );
  }
}

class PurchaseItem {
  final int id;
  final String number;
  final String subject;
  final String status;
  final double total;
  final String createdTime;

  PurchaseItem({
    required this.id,
    required this.number,
    required this.subject,
    required this.status,
    required this.total,
    required this.createdTime,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: (json['id'] ?? 0) as int,
      number: (json['number'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      total: (json['total'] ?? 0).toDouble(),
      createdTime: (json['createdtime'] ?? '').toString(),
    );
  }
}