import 'package:flutter/material.dart';

import '../data/pravna_remote_datasource.dart';

class PravnaNotifier extends ChangeNotifier {

 final PravnaRemoteDatasource
    datasource;

 PravnaNotifier(
   this.datasource,
 );

 bool loading=false;

 Map<String,dynamic>? profile;

 /* ================= LOGIN ================= */

 Future<bool> login(
   String companyId,
   String password,
 ) async {

   try{

    loading=true;
    notifyListeners();

    final res=
      await datasource.login(
         companyId,
         password,
      );

    debugPrint(
      "PRAVNA LOGIN RESPONSE: $res",
    );

    loading=false;

    if(
      res["success"]==true ||
      res["status"]=="success"
    ){

      // 🔥 sačuvaj profil odmah iz logina
      profile = res;

      debugPrint(
       "PROFILE SAVED: $profile",
      );

      notifyListeners();

      return true;
    }

    notifyListeners();

    return false;

   } catch(e){

      debugPrint(
       "LOGIN ERROR: $e",
      );

      loading=false;
      notifyListeners();

      return false;
   }
 }

 /* ================= PROFILE ================= */

 Future<void> loadProfile()
 async {

  try{

   loading=true;
   notifyListeners();

   final res=
      await datasource
         .getProfile();

   if(
      res["success"]==true
   ){
      profile=res;
   }

   loading=false;
   notifyListeners();

  } catch(e){

   debugPrint(
    "PROFILE ERROR: $e",
   );

   loading=false;
   notifyListeners();

  }

 }

 Map<String,dynamic>? getProfileData(){
   return profile;
 }

 /* ================= TICKET ================= */

 Future<Map<String,dynamic>>
 createTicket(
   Map<String,dynamic> data,
 ) async {

   return await datasource
      .createTicket(data);
 }

}