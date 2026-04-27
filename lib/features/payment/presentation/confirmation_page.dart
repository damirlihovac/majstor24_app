import 'package:flutter/material.dart';

class ConfirmationPage extends StatelessWidget {
  const ConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Confirmation')),
      body: const Center(
        child: Text('Your payment was successful!'),
      ),
    );
  }
}