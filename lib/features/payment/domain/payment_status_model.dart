class PaymentStatus {
  final String status;
  final String? entityId;

  PaymentStatus({
    required this.status,
    this.entityId,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    final rawStatus = (json["status"] ?? "").toString();

    return PaymentStatus(
      status: rawStatus.toUpperCase().trim(), // 🔥 NORMALIZACIJA
      entityId: json["entity_id"]?.toString() ??
          json["ticket_id"]?.toString() ??
          json["opportunity_id"]?.toString() ??
          json["payment_id"]?.toString(),
    );
  }

  /* ======================================
     STATUS LOGIKA
  ====================================== */

  bool get isDone =>
      status == "DONE" ||
      status == "CREATED"; // 🔥 KLJUČNO ZA TICKET

  bool get isError =>
      status == "ERROR" ||
      status == "FAILED";
}