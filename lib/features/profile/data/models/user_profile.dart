import 'package:flutter/material.dart';
import 'package:majstor24_app/core/network/api_client.dart';

class UserProfile extends ChangeNotifier {

  final ApiClient _api = ApiClient();

  bool loading = false;

  String? contactId;
  String? firstname;
  String? lastname;
  String? email;
  String? mobile;
  String? mailingstreet;
  String? mailingzip;
  String? mailingcity;

  List cards = [];

  /*
  =========================
  UPDATE FROM JSON
  =========================
  */

  void updateFromJson(Map<String,dynamic> data) {

    contactId = data["contact_id"]?.toString();
    firstname = data["firstname"];
    lastname = data["lastname"];
    email = data["email"];
    mobile = data["mobile"];
    mailingstreet = data["mailingstreet"];
    mailingzip = data["mailingzip"];
    mailingcity = data["mailingcity"];

    notifyListeners();

  }

  /*
  =========================
  LOAD PROFILE FROM API
  =========================
  */

  Future<void> loadProfile() async {

    loading = true;
    notifyListeners();

    try {

      final res = await _api.get("profile/get.php");

      if (res["success"] == true) {

        updateFromJson(res["user"]);

      }

    } catch (e) {

      debugPrint("PROFILE LOAD ERROR: $e");

    }

    loading = false;
    notifyListeners();

  }

  /*
  =========================
  LOAD CARDS
  =========================
  */

  Future<void> loadCards() async {

    try {

      final res = await _api.post(
        "payment/get_registered_cards_mobile.php"
      );

      if (res["success"] == true) {

        cards = res["cards"] ?? [];

      }

    } catch (e) {

      debugPrint("CARDS LOAD ERROR: $e");

    }

    notifyListeners();

  }

  /*
  =========================
  LOAD ALL
  =========================
  */

  Future<void> loadAll() async {

    await loadProfile();
    await loadCards();

  }

}