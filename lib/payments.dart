// payment_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reservations.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final amountController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser!;

  void addMockPayment() async {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;
    if (amount <= 0) return;

    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments')
        .add({
      'amount': amount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(userRef);
      final currentBalance = snapshot.data()?['balance'] ?? 0;
      tx.update(userRef, {'balance': currentBalance + amount});
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment of ₪$amount added.')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ReservationPage()),
    );
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
              onPressed: addMockPayment,
              child: const Text('Simulate Payment'),
            ),
          ],
        ),
      ),
    );
  }
}
