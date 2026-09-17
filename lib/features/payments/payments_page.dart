// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/page_header.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  static String _formatAmount(double amount) {
    return amount.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const PageHeader(title: 'Mes paiements'),
              const Expanded(
                child: Center(
                  child: Text(
                    'Vous devez être connecté pour consulter vos paiements.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const BaoBottomNav(selectedIndex: 3),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Mes paiements'),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('payments')
                    .where('userId', isEqualTo: user.uid)
                    .snapshots(),

                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Impossible de charger les paiements.\n\n'
                          '${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final documents = snapshot.data?.docs ?? [];

                  final paid = documents
                      .where((doc) => _isPaid(doc.data()['status']))
                      .fold<double>(
                        0,
                        (total, doc) =>
                            total + _readAmount(doc.data()['amount']),
                      );
                  final pending = documents
                      .where((doc) => !_isPaid(doc.data()['status']))
                      .fold<double>(
                        0,
                        (total, doc) =>
                            total + _readAmount(doc.data()['amount']),
                      );
                  final summary = _PaymentSummary(paid: paid, pending: pending);

                  if (documents.isEmpty) {
                    final demoPayments = [
                      (
                        'Récolte de coton',
                        30000.0,
                        'paid',
                        DateTime(2026, 5, 6),
                      ),
                      ('Semis de maïs', 25000.0, 'paid', DateTime(2026, 5, 2)),
                      (
                        'Entretien champ',
                        20000.0,
                        'paid',
                        DateTime(2026, 5, 15),
                      ),
                    ];
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        const _PaymentSummary(paid: 75000, pending: 0),
                        const SizedBox(height: 16),
                        ...demoPayments.map(
                          (payment) => _PaymentCard(
                            missionTitle: payment.$1,
                            amount: payment.$2,
                            status: payment.$3,
                            date: payment.$4,
                          ),
                        ),
                      ],
                    );
                  }

                  documents.sort((a, b) {
                    final aData = a.data();
                    final bData = b.data();

                    final aDate = _readDate(aData['createdAt']);
                    final bDate = _readDate(bData['createdAt']);

                    return bDate.compareTo(aDate);
                  });

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      summary,
                      const SizedBox(height: 16),
                      ...documents.map((document) {
                        final data = document.data();

                        final missionTitle =
                            data['missionTitle']?.toString() ?? 'Mission';

                        final amount = _readAmount(data['amount']);

                        final status =
                            data['status']?.toString() ?? 'en_attente';

                        final date = _readDate(data['createdAt']);

                        return _PaymentCard(
                          missionTitle: missionTitle,
                          amount: amount,
                          status: status,
                          date: date,
                        );
                      }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BaoBottomNav(selectedIndex: 3),
    );
  }

  static double _readAmount(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _readDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static bool _isPaid(dynamic status) => {
    'paid',
    'payé',
    'paid_out',
    'completed_payment',
  }.contains(status?.toString().toLowerCase());
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({required this.paid, required this.pending});
  final double paid;
  final double pending;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: _SummaryItem(
          label: 'Déjà payé',
          amount: paid,
          color: Colors.green,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _SummaryItem(
          label: 'À payer',
          amount: pending,
          color: Colors.orange,
        ),
      ),
    ],
  );
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.amount,
    required this.color,
  });
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            '${PaymentsPage._formatAmount(amount)} FCFA',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    ),
  );
}

class _PaymentCard extends StatelessWidget {
  final String missionTitle;
  final double amount;
  final String status;
  final DateTime date;

  const _PaymentCard({
    required this.missionTitle,
    required this.amount,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final statusInfo = _statusInfo(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.payments_outlined,
                    color: Colors.green,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        missionTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatDate(date),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${_formatAmount(amount)} FCFA',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Icon(statusInfo.icon, size: 18, color: statusInfo.color),

                const SizedBox(width: 6),

                Text(
                  statusInfo.label,
                  style: TextStyle(
                    color: statusInfo.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double amount) {
    return amount.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]} ',
    );
  }

  static String _formatDate(DateTime date) {
    if (date.millisecondsSinceEpoch == 0) {
      return 'Date non renseignée';
    }

    final day = date.day.toString().padLeft(2, '0');

    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  static _StatusInfo _statusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'paye':
      case 'payé':
      case 'completed':
      case 'complete':
      case 'completed_payment':
        return const _StatusInfo(
          label: 'Paiement effectué',
          color: Colors.green,
          icon: Icons.check_circle_outline,
        );

      case 'pending':
      case 'en_attente':
      case 'en attente':
        return const _StatusInfo(
          label: 'Paiement en attente',
          color: Colors.orange,
          icon: Icons.schedule,
        );

      case 'failed':
      case 'echoue':
      case 'échoué':
        return const _StatusInfo(
          label: 'Paiement échoué',
          color: Colors.red,
          icon: Icons.error_outline,
        );

      default:
        return const _StatusInfo(
          label: 'Statut non renseigné',
          color: Colors.grey,
          icon: Icons.info_outline,
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}
