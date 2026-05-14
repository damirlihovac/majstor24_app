import 'package:flutter/foundation.dart';
import 'package:majstor24_app/core/auth/auth_storage.dart';
import 'package:majstor24_app/core/network/api_client.dart';

class PravnaRemoteDatasource {

  final ApiClient _api;
  final AuthStorage _storage = AuthStorage();

  PravnaRemoteDatasource(this._api);

  /* ================= LOGIN ================= */

Future<Map<String,dynamic>> login(
  String companyId,
  String password,
) async {

  debugPrint(
    "PRAVNA LOGIN ID: $companyId",
  );

  final res = await _api.post(

    "login_pravno.php",

    body: {

      "idbroj": companyId,
      "sifra": password,
    },
  );

  debugPrint(
    "LOGIN RESPONSE: $res",
  );

  if (
      res["success"] == true &&
      res["token"] != null
  ) {

    await _storage.saveToken(
      res["token"].toString(),
    );

    debugPrint(
      "PRAVNA TOKEN SAVED: ${res["token"]}",
    );
  }

  return res;
}

  /* ================= PROFILE ================= */
  /* ⚠️ koristi samo ako session radi */
  Future<Map<String,dynamic>> getProfile() async {

    final res = await _api.get(
      "get_company_profile.php",
    );

    return res;
  }

  /* ================= SALES ORDERS ================= */

  Future<Map<String,dynamic>> getSalesOrders({
    required int contactId,
  }) async {

    debugPrint("CONTACT ID (ORDERS): $contactId");

    final res = await _api.post(
      "get_salesorders_pravna.php",
      body: {
        "contact_id": contactId,
      },
    );

    debugPrint("ORDERS RESPONSE: $res");

    return res;
  }

  /* ================= CONTRACTS ================= */

  Future<Map<String,dynamic>> getContracts({
    required int contactId,
  }) async {

    debugPrint("CONTACT ID (CONTRACTS): $contactId");

    final res = await _api.post(
      "get_service_contracts_company.php",
      body: {
        "contact_id": contactId,
      },
    );

    debugPrint("CONTRACTS RESPONSE: $res");

    return res;
  }

  /* ================= INVOICES ================= */

  Future<Map<String,dynamic>> getInvoices({
    required int contactId,
  }) async {

    debugPrint("CONTACT ID (INVOICES): $contactId");

    final res = await _api.post(
      "get_invoices_company.php",
      body: {
        "contact_id": contactId,
      },
    );

    debugPrint("INVOICES RESPONSE: $res");

    return res;
  }

  /* ================= CREATE TICKET ================= */

  Future<Map<String,dynamic>> createTicket(
    Map<String,dynamic> data
  ) async {

    final res = await _api.post(
      "create_ticket_pravna.php",
      body: data,
    );

    debugPrint("CREATE TICKET RESPONSE: $res");

    return res;
  }
}