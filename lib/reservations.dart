import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'payments.dart';

class ReservationPage extends StatefulWidget {
  const ReservationPage({super.key});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final user = FirebaseAuth.instance.currentUser!;
  DateTime selectedDate = DateTime.now();
  List<String> hours = List.generate(16, (i) => '${i + 7}:00');
  final courts = List.generate(6, (i) => i + 1);
  Map<String, Map<int, Map<String, dynamic>>> reservations = {};
  double currentBalance = 0;

  @override
  void initState() {
    super.initState();
    loadReservations();
    loadBalance();
  }

  Future<void> loadBalance() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    setState(() {
      currentBalance = (userDoc.data()?['balance'] ?? 0).toDouble();
    });
  }

  Future<void> loadReservations() async {
    final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);
    final query = await FirebaseFirestore.instance
        .collection('reservations')
        .where('date', isEqualTo: dateString)
        .get();

    final Map<String, Map<int, Map<String, dynamic>>> temp = {};
    for (var doc in query.docs) {
      final data = doc.data();
      final time = data['time'];
      final court = data['court'];
      temp[time] ??= {};
      temp[time]![court] = {
        ...data,
        'id': doc.id,
      };
    }

    setState(() => reservations = temp);
  }

  Future<void> reserveCourt(String time, int court) async {
    if (currentBalance < 30) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => const PaymentPage()));
      return;
    }

    final dateString = DateFormat('yyyy-MM-dd').format(selectedDate);

    await FirebaseFirestore.instance.collection('reservations').add({
      'userId': user.uid,
      'userName': user.email,
      'date': dateString,
      'time': time,
      'court': court,
    });

    await FirebaseFirestore.instance.runTransaction((tx) async {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final snapshot = await tx.get(userRef);
      final balance = (snapshot.data()?['balance'] ?? 0).toDouble();
      tx.update(userRef, {'balance': balance - 30});
    });

    await loadReservations();
    await loadBalance();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Court $court reserved for $time'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> cancelReservation(String? reservationId) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection('reservations')
          .doc(reservationId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.delete();
        await loadReservations();
      }
    } catch (e) {}
  }

  Widget buildCourtButton(String time, int court) {
    final res = reservations[time]?[court];

    Color color;
    String label;
    VoidCallback? onPressed;

    if (res == null) {
      color = Colors.green;
      label = 'Free';
      onPressed = () => reserveCourt(time, court);
    } else if (res['userId'] == user.uid) {
      color = Colors.blue;
      label = 'Yours';
      onPressed = () => cancelReservation(res['id']);
    } else {
      color = Colors.red;
      label = 'Taken';
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Court Reservation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                      await loadReservations();
                    }
                  },
                  child: Text(
                    DateFormat('EEE, MMM d, yyyy').format(selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaymentPage()),
                    );
                  },
                  child: Text('Balance: ₪${currentBalance.toStringAsFixed(0)}'),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;

                if (details.primaryVelocity! < 0) {
                  setState(() =>
                      selectedDate = selectedDate.add(const Duration(days: 1)));
                  loadReservations();
                } else if (details.primaryVelocity! > 0) {
                  setState(() => selectedDate =
                      selectedDate.subtract(const Duration(days: 1)));
                  loadReservations();
                }
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 800,
                  child: SingleChildScrollView(
                    child: Table(
                      border: TableBorder.all(),
                      defaultVerticalAlignment:
                          TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          children: [
                            const TableCell(child: Center(child: Text('Hour'))),
                            ...courts.map((court) => TableCell(
                                  child: Center(child: Text('Court $court')),
                                )),
                          ],
                        ),
                        ...hours.map((time) {
                          return TableRow(
                            children: [
                              TableCell(child: Center(child: Text(time))),
                              ...courts.map((court) {
                                return TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: buildCourtButton(time, court),
                                  ),
                                );
                              }),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
