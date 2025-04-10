// payment_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final amountController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  void launchTranzilaIframe() async {
    final amount = amountController.text.trim();
    final supplier = 'fxpmikron30';
    final successUrl = Uri.encodeComponent(
        'https://tennis-motzkin-9t5of.ondigitalocean.app/#/payment_success?sum=$amount');
    final errorUrl = Uri.encodeComponent(
        'https://tennis-motzkin-9t5of.ondigitalocean.app/#/payment_error');

    final tranzilaUrl = Uri.parse(
      'https://direct.tranzila.com/$supplier/iframe.php'
      '?sum=$amount'
      '&currency=1'
      '&success_url=$successUrl'
      '&error_url=$errorUrl'
      '&lang=il',
    );

    if (await canLaunchUrl(tranzilaUrl)) {
      await launchUrl(tranzilaUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch Tranzila payment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Up Balance')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text('Enter amount (₪):'),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: launchTranzilaIframe,
              child: const Text('Pay with Tranzila'),
            ),
          ],
        ),
      ),
    );
  }
}
