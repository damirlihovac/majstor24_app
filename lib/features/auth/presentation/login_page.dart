import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../application/auth_notifier.dart';
import '../../home/presentation/home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBrandTitle(),
                  const SizedBox(height: 16),
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 24),
                  _buildLoginButton(context, auth),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI PARTS =================

  Widget _buildBrandTitle() {
    return const Text(
      'Brza kućna asistencija',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: Color(0xFF111111),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/majstor24b.png',
        height: 80,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(
        label: 'Email ili telefon',
        hint: 'email@primjer.ba',
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: _inputDecoration(
        label: 'Password',
        hint: '••••••••',
      ),
    );
  }

  // ================= LOGIN BUTTON =================

  Widget _buildLoginButton(BuildContext context, AuthNotifier auth) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: auth.state.isLoading
            ? null
            : () async {
                final identifier = _emailController.text.trim();
                final password = _passwordController.text.trim();

                if (identifier.isEmpty || password.isEmpty) {
                  _showError(context, 'Unesite email/telefon i lozinku.');
                  return;
                }

                await auth.login(identifier, password);

                if (!context.mounted) return;

                if (auth.state.isAuthenticated) {
                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
                  );
                } else if (auth.state.error != null) {
                  _showError(context, auth.state.error!);
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111111),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: auth.state.isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Prijava',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return const Text(
      '© majstor24.ba',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF777777),
      ),
    );
  }

  // ================= HELPERS =================

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}