import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:majstor24_app/features/auth/application/auth_notifier.dart';
import 'package:majstor24_app/features/auth/presentation/auth_landing_page.dart';
import 'package:majstor24_app/features/auth/presentation/auth_landing_page_pravna.dart';
import 'package:majstor24_app/features/auth/presentation/auth_landing_page_izvrsilac.dart';

import 'package:majstor24_app/features/profile/data/models/user_profile.dart';
import 'package:majstor24_app/features/profile/data/profile_remote_datasource.dart';

import 'package:majstor24_app/core/network/api_client.dart';
import 'package:majstor24_app/core/role_manager.dart';

import 'package:majstor24_app/features/home/presentation/home_page.dart';
import 'package:majstor24_app/features/pravna/presentation/pravna_home.dart';
import 'package:majstor24_app/features/izvrsilac/presentation/izvrsilac_home.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() =>
      _AuthGateState();
}

class _AuthGateState
    extends State<AuthGate> {

  bool _loading = true;

  final ApiClient _apiClient =
      ApiClient();

  /* DEVELOPMENT MODE:
     uvijek prvo login screen */
  static const bool forceLogin = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {

    final auth =
      context.read<AuthNotifier>();

    debugPrint(
      "INIT LOGGED IN: ${auth.isLoggedIn}",
    );

    if(
      !auth.isLoggedIn ||
      forceLogin
    ){
      if(mounted){
        setState(
         ()=> _loading=false,
        );
      }
      return;
    }

    Future.microtask(() async {

      try {

        final profileDs=
          ProfileRemoteDatasource(
            _apiClient,
          );

        final data=
          await profileDs
              .getProfile();

        if(
          data.isNotEmpty &&
          mounted
        ){
          context
            .read<UserProfile>()
            .updateFromJson(
              data,
            );
        }

      } catch(e){

        debugPrint(
          "PROFILE ERROR: $e",
        );
      }

    });

    if(mounted){
      setState(
       ()=> _loading=false,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ){

    final auth=
      context.watch<AuthNotifier>();

    final role=
      RoleManager.role;

    debugPrint(
      "AUTH STATUS: ${auth.isLoggedIn}",
    );

    debugPrint(
      "CURRENT ROLE: $role",
    );

    if(_loading){
      return const Scaffold(
        body: Center(
          child:
            CircularProgressIndicator(),
        ),
      );
    }

    /* FORCE LOGIN MODE */
    if(forceLogin){

      if(role=="pravna"){
        return const AuthLandingPagePravna();
      }

      if(role=="izvrsilac"){
        return const AuthLandingPageIzvrsilac();
      }

      return const AuthLandingPage();
    }

    /* NORMAL FLOW */
    if(!auth.isLoggedIn){

      if(role=="pravna"){
        return const AuthLandingPagePravna();
      }

      if(role=="izvrsilac"){
        return const AuthLandingPageIzvrsilac();
      }

      return const AuthLandingPage();
    }

    /* LOGGED USERS */
    switch(role){

      case "pravna":
        return const PravnaHome();

      case "izvrsilac":
        return const IzvrsilacHome();

case "fizicka":
default:
  return const HomePage();

    }
  }
}