import 'package:flutter/material.dart';
import 'reservations.dart';

class PaymentErrorPage extends StatelessWidget {
  const PaymentErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('תשלום נכשל')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text(
              'התשלום לא הושלם בהצלחה.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ReservationPage()),
                );
              },
              child: const Text('חזרה להזמנות'),
            )
          ],
        ),
      ),
    );
  }
}
