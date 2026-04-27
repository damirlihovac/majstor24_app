import 'dart:convert';
import 'package:http/http.dart' as http;
import 'profile_models.dart';

class ProfileApi {
  final String baseUrl;
  final Future<String?> Function() getToken;

  ProfileApi({
    required this.baseUrl,
    required this.getToken,
  });

  Future<Map<String, String>> _headers() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('TOKEN_MISSING');
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  Future<List<PaymentCardItem>> getCards() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/get_registered_cards_mobile.php'),
      headers: await _headers(),
    );

    final jsonBody = jsonDecode(res.body);

    if (res.statusCode != 200 || jsonBody['success'] != true) {
      throw Exception(jsonBody['message'] ?? 'GET_CARDS_FAILED');
    }

    final List<dynamic> rows = (jsonBody['cards'] ?? []) as List<dynamic>;
    return rows
        .map((e) => PaymentCardItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ServiceContractItem>> getAccounts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/get_service_contracts_mobile.php'),
      headers: await _headers(),
    );

    final jsonBody = jsonDecode(res.body);

    if (res.statusCode != 200 || jsonBody['success'] != true) {
      throw Exception(jsonBody['message'] ?? 'GET_ACCOUNTS_FAILED');
    }

    final List<dynamic> rows = (jsonBody['result'] ?? []) as List<dynamic>;
    return rows
        .map((e) => ServiceContractItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<InvoiceItem>> getInvoices() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/get_invoices_mobile.php'),
      headers: await _headers(),
    );

    final jsonBody = jsonDecode(res.body);

    if (res.statusCode != 200 || jsonBody['success'] != true) {
      throw Exception(jsonBody['message'] ?? 'GET_INVOICES_FAILED');
    }

    final List<dynamic> rows = (jsonBody['result'] ?? []) as List<dynamic>;
    return rows
        .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PurchaseItem>> getPurchases() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/get_salesorders_mobile.php'),
      headers: await _headers(),
    );

    final jsonBody = jsonDecode(res.body);

    if (res.statusCode != 200 || jsonBody['success'] != true) {
      throw Exception(jsonBody['message'] ?? 'GET_PURCHASES_FAILED');
    }

    final List<dynamic> rows = (jsonBody['result'] ?? []) as List<dynamic>;
    return rows
        .map((e) => PurchaseItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}