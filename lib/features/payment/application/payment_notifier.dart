import 'package:flutter/material.dart';
import 'package:majstor24_app/core/network/api_client.dart';

enum PaymentStatus {
  idle,
  starting,
  waitingGateway,
  verifying,
  success,
  failed,
}

class PaymentNotifier extends ChangeNotifier {

  final ApiClient _api = ApiClient();

  PaymentStatus _status = PaymentStatus.idle;

  String? _trx;
  String? _redirectUrl;
  String? _errorMessage;

  PaymentStatus get status => _status;

  String? get trx => _trx;

  String? get redirectUrl => _redirectUrl;

  String? get errorMessage => _errorMessage;

  bool get isLoading =>
      _status == PaymentStatus.starting ||
      _status == PaymentStatus.verifying;

  bool get isWaitingGateway =>
      _status == PaymentStatus.waitingGateway;

  bool get isSuccess =>
      _status == PaymentStatus.success;

  bool get isFailed =>
      _status == PaymentStatus.failed;

  void reset() {
    _status = PaymentStatus.idle;
    _trx = null;
    _redirectUrl = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Pokretanje plaćanja
  Future<String?> startPayment({
    required String trx,
    required int cardId,
  }) async {

    if (_status == PaymentStatus.starting) {
      return null;
    }

    _status = PaymentStatus.starting;
    _trx = trx;
    _errorMessage = null;
    notifyListeners();

    try {

final response = await _api.post(
  "payment/start_bankart_transaction.php",
  body: {
    "trx": trx,
    "card_id": cardId,
  },
);;

      if (response["success"] != true) {

        _status = PaymentStatus.failed;
        _errorMessage =
            response["message"] ?? "Payment start failed";

        notifyListeners();
        return null;
      }

      _redirectUrl = response["redirectUrl"];

      _status = PaymentStatus.waitingGateway;

      notifyListeners();

      return _redirectUrl;

    } catch (e) {

      _status = PaymentStatus.failed;
      _errorMessage = e.toString();

      notifyListeners();

      return null;
    }
  }

  /// Verifikacija nakon deep linka
  Future<bool> verifyPayment(String trx) async {

    _status = PaymentStatus.verifying;
    notifyListeners();

    try {

      final response = await _api.get(
        "payment/verify_ticket_payment.php?trx=$trx",
      );

      final success = response["success"] == true;

      if (!success) {

        _status = PaymentStatus.failed;
        _errorMessage =
            response["message"] ?? "Payment failed";

        notifyListeners();

        return false;
      }

      final status = response["status"]?.toString();

      if (status == "TICKET_CREATED" ||
          status == "PAID" ||
          status == "SUCCESS") {

        _status = PaymentStatus.success;

        notifyListeners();

        return true;
      }

      _status = PaymentStatus.failed;
      _errorMessage = "Unknown payment status";

      notifyListeners();

      return false;

    } catch (e) {

      _status = PaymentStatus.failed;
      _errorMessage = e.toString();

      notifyListeners();

      return false;
    }
  }
}