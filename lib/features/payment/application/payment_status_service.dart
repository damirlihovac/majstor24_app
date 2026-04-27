import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/payment_status_model.dart';

class PaymentStatusService {

  static const _base = "https://majstor24.ba/api/payment";

  /* ======================================
     GENERIC CHECK (ENTERPRISE)
  ====================================== */

  static Future<PaymentStatus> _check(String url) async {
    try {
      final uri = Uri.parse(url);

      final res = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      /* ======================================
         DEBUG (KLJUČNO)
      ====================================== */
      print("CHECK URL: $url");
      print("STATUS CODE: ${res.statusCode}");
      print("RAW BODY: ${res.body}");

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}");
      }

      final json = jsonDecode(res.body);

      if (json is! Map<String, dynamic>) {
        throw Exception("INVALID JSON");
      }

      return PaymentStatus.fromJson(json);

    } catch (e) {
      print("PAYMENT STATUS ERROR: $e");

      return PaymentStatus(
        status: "ERROR",
        entityId: null,
      );
    }
  }

  /* ======================================
     PACKAGE
  ====================================== */

  static Future<PaymentStatus> checkPackage(String trx) async {
    return _check("$_base/check_package_status.php?trx=$trx");
  }

  /* ======================================
     TICKET
  ====================================== */

  static Future<PaymentStatus> checkTicket(String trx) async {
    return _check("$_base/check_ticket_status.php?trx=$trx");
  }

  /* ======================================
     CARD
  ====================================== */

  static Future<PaymentStatus> checkCard(String trx) async {
    return _check("$_base/check_card_status.php?trx=$trx");
  }
}