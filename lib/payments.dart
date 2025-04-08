import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final amountController = TextEditingController();

  void launchTranzilaPayment() async {
    final amount = amountController.text;
    final supplier =
        'YOUR_TERMINAL_NAME'; // Replace with your real Tranzila terminal name
    final successUrl = Uri.encodeComponent('https://yourwebsite.com/success');
    final errorUrl = Uri.encodeComponent('https://yourwebsite.com/error');

    final url = Uri.parse(
      'https://direct.tranzila.com/$supplier/iframe.php'
      '?sum=$amount'
      '&currency=1'
      '&success_url=$successUrl'
      '&error_url=$errorUrl'
      '&lang=il',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch Tranzila payment URL';
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
              onPressed: launchTranzilaPayment,
              child: const Text('Pay with Tranzila'),
            ),
          ],
        ),
      ),
    );
  }
}
