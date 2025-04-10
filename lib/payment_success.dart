// payment_success.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'reservations.dart';

class PaymentSuccessPage extends StatefulWidget {
  final double amount;
  const PaymentSuccessPage({super.key, required this.amount});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final user = FirebaseAuth.instance.currentUser!;
  bool isProcessing = true;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  Future<void> _processPayment() async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('payments')
          .add({
        'amount': widget.amount,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snapshot = await tx.get(userRef);
        final currentBalance = snapshot.data()?['balance'] ?? 0;
        tx.update(userRef, {'balance': currentBalance + widget.amount});
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReservationPage()),
        );
      }
    } catch (e) {
      setState(() => isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update payment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Processing Payment')),
      body: Center(
        child: isProcessing
            ? const CircularProgressIndicator()
            : const Text('Something went wrong...'),
      ),
    );
  }
}
