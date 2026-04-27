import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

import 'package:majstor24_app/core/router/app_router.dart';

import 'package:majstor24_app/features/auth/application/auth_notifier.dart';
import 'package:majstor24_app/features/auth/presentation/auth_gate.dart';

import 'package:majstor24_app/features/payment/application/payment_notifier.dart';

import 'package:majstor24_app/features/profile/presentation/profile_page.dart';
import 'package:majstor24_app/features/profile/data/models/user_profile.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authNotifier = AuthNotifier();
  await authNotifier.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>.value(
          value: authNotifier,
        ),
        ChangeNotifierProvider<UserProfile>(
          create: (_) => UserProfile(),
        ),
        ChangeNotifierProvider<PaymentNotifier>(
          create: (_) => PaymentNotifier(),
        ),
      ],
      child: const Majstor24App(),
    ),
  );
}

class Majstor24App extends StatefulWidget {
  const Majstor24App({super.key});

  @override
  State<Majstor24App> createState() => _Majstor24AppState();
}

class _Majstor24AppState extends State<Majstor24App> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  String? _lastTxHandled;
  DateTime? _lastHandledAt;

  @override
  void initState() {
    super.initState();

    _appLinks = AppLinks();

    _initInitialLink();

    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) => _handleIncomingLink(uri),
      onError: (err) {
        debugPrint("APP LINKS ERROR: $err");
      },
    );
  }

  Future<void> _initInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        await _handleIncomingLink(uri);
      }
    } catch (e) {
      debugPrint("INITIAL LINK ERROR: $e");
    }
  }

  bool _isDuplicateTx(String tx) {
    final now = DateTime.now();

    if (_lastTxHandled == tx && _lastHandledAt != null) {
      final diff = now.difference(_lastHandledAt!);
      if (diff.inSeconds <= 3) {
        return true;
      }
    }

    _lastTxHandled = tx;
    _lastHandledAt = now;

    return false;
  }

  Future<void> _handleIncomingLink(Uri uri) async {
    debugPrint("APP LINK RECEIVED: $uri");

    final context = navigatorKey.currentContext;
    if (context == null) return;

    if (uri.scheme == 'majstor24' &&
        uri.host == 'payment-result') {

      final tx =
          uri.queryParameters['trx'] ??
          uri.queryParameters['tx'];

      if (tx == null || tx.isEmpty) return;

      if (_isDuplicateTx(tx)) return;

      debugPrint("DEEP LINK FALLBACK TRIGGERED");

      try {
        final payment = context.read<PaymentNotifier>();

        final success = await payment.verifyPayment(tx);

        if (success) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const AuthGate(),
            ),
            (route) => false,
          );

          Future.microtask(() {
            final ctx = navigatorKey.currentContext;
            if (ctx != null) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                const SnackBar(
                  content: Text("Zahtjev uspješno kreiran"),
                ),
              );
            }
          });
        }

      } catch (e) {
        debugPrint("VERIFY ERROR: $e");
      }

      return;
    }

    if (uri.scheme == 'majstor24' &&
        uri.host == 'card-register-result') {

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const ProfilePage(),
        ),
        (route) => false,
      );

      return;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, auth, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'majstor24.ba',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const AuthGate(),
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}