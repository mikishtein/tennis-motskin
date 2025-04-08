import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentSuccessPage extends StatefulWidget {
  final double amount;

  const PaymentSuccessPage({super.key, required this.amount});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  String status = 'Processing...';

  @override
  void initState() {
    super.initState();
    storePayment();
  }

  Future<void> storePayment() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => status = 'User not found');
      return;
    }

    final paymentsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('payments');

    await paymentsRef.add({
      'amount': widget.amount,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Also update balance
    final userRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snapshot = await tx.get(userRef);
      final currentBalance = snapshot.data()?['balance'] ?? 0.0;
      tx.update(userRef, {'balance': currentBalance + widget.amount});
    });

    setState(() => status = 'Payment recorded successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Success')),
      body: Center(child: Text(status)),
    );
  }
}
