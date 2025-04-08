import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'update_password.dart';
import 'payments.dart';
import 'reservations.dart';
import 'terms.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${user?.email ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You are logged in!'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const ReservationPage(),
                ));
              },
              child: const Text('Reserve a Court'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const PaymentPage(),
                ));
              },
              child: const Text('Top Up Balance'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const UpdatePasswordPage(),
                ));
              },
              child: const Text('Update Password'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const TermsPage(),
                ));
              },
              child: const Text('תקנון החזרים וביטולים'),
            ),
          ],
        ),
      ),
    );
  }
}
