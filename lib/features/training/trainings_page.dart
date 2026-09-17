import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../shared/firebase_service.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/widgets/bottom_nav.dart';
import '../../shared/widgets/page_header.dart';

class TrainingsPage extends StatefulWidget {
  const TrainingsPage({super.key});

  @override
  State<TrainingsPage> createState() => _TrainingsPageState();
}

class _TrainingsPageState extends State<TrainingsPage> {
  @override
  void initState() {
    super.initState();
    unawaited(FirebaseService().ensureMasterData().catchError((_) {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Mes batchs'),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('batches')
                    .where('active', isEqualTo: true)
                    .orderBy('order')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final batches = snapshot.data?.docs ?? [];
                  if (batches.isEmpty) {
                    return const Center(
                      child: Text('Aucun batch disponible pour le moment.'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: batches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = batches[index];
                      return _BatchTile(
                        batchId: doc.id,
                        batch: doc.data(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BatchDetailPage(
                              batchId: doc.id,
                              batch: doc.data(),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BaoBottomNav(selectedIndex: 5),
    );
  }
}

class _BatchTile extends StatelessWidget {
  const _BatchTile({
    required this.batchId,
    required this.batch,
    required this.onTap,
  });

  final String batchId;
  final Map<String, dynamic> batch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final trainingStream = FirebaseFirestore.instance
        .collection('trainings')
        .where('batchId', isEqualTo: batchId)
        .where('active', isEqualTo: true)
        .snapshots();
    final progressStream = uid == null
        ? const Stream<QuerySnapshot<Map<String, dynamic>>>.empty()
        : FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('trainingProgress')
              .where('batchId', isEqualTo: batchId)
              .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: trainingStream,
      builder: (context, trainingSnapshot) {
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: progressStream,
          builder: (context, progressSnapshot) {
            final total = trainingSnapshot.data?.docs.length ?? 0;
            final completed =
                progressSnapshot.data?.docs
                    .where((doc) => doc.data()['status'] == 'completed')
                    .length ??
                0;
            final validated = total > 0 && completed >= total;
            return Card(
              child: ListTile(
                onTap: onTap,
                leading: CircleAvatar(
                  backgroundColor: validated
                      ? AppTheme.green.withValues(alpha: 0.14)
                      : AppTheme.orange.withValues(alpha: 0.14),
                  child: Icon(
                    validated ? Icons.verified_outlined : Icons.school_outlined,
                    color: validated ? AppTheme.green : AppTheme.orange,
                  ),
                ),
                title: Text(
                  batch['name']?.toString() ?? 'Batch',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  validated
                      ? 'Validé'
                      : completed == 0
                      ? 'Batch non validé'
                      : 'En cours • $completed/$total formations',
                  style: TextStyle(
                    color: validated ? AppTheme.green : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right),
              ),
            );
          },
        );
      },
    );
  }
}

class BatchDetailPage extends StatelessWidget {
  const BatchDetailPage({
    super.key,
    required this.batchId,
    required this.batch,
  });

  final String batchId;
  final Map<String, dynamic> batch;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Vous devez être connecté.')),
      );
    }
    final trainingStream = FirebaseFirestore.instance
        .collection('trainings')
        .where('batchId', isEqualTo: batchId)
        .where('active', isEqualTo: true)
        .orderBy('order')
        .snapshots();
    final progressStream = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('trainingProgress')
        .where('batchId', isEqualTo: batchId)
        .snapshots();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            PageHeader(title: batch['name']?.toString() ?? 'Batch'),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: trainingStream,
                builder: (context, trainingSnapshot) {
                  final trainings = trainingSnapshot.data?.docs ?? [];
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: progressStream,
                    builder: (context, progressSnapshot) {
                      final progress = {
                        for (final doc in progressSnapshot.data?.docs ?? [])
                          doc.id: doc.data(),
                      };
                      final completed = trainings
                          .where(
                            (doc) => progress[doc.id]?['status'] == 'completed',
                          )
                          .length;
                      final validated =
                          trainings.isNotEmpty && completed == trainings.length;
                      return ListView(
                        padding: const EdgeInsets.all(14),
                        children: [
                          Text(
                            batch['description']?.toString() ?? '',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 12),
                          _StatusBanner(
                            validated: validated,
                            completed: completed,
                            total: trainings.length,
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Formations du batch',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                            ),
                          ),
                          if (trainings.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 16),
                              child: Text('Aucune formation disponible.'),
                            )
                          else
                            ...trainings.map(
                              (doc) => _TrainingTile(
                                trainingId: doc.id,
                                training: doc.data(),
                                progress: progress[doc.id],
                                batchId: batchId,
                                batchName: batch['name']?.toString() ?? 'Batch',
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.validated,
    required this.completed,
    required this.total,
  });

  final bool validated;
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: validated
            ? AppTheme.green.withValues(alpha: 0.12)
            : AppTheme.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            validated ? Icons.verified : Icons.pending_outlined,
            color: validated ? AppTheme.green : AppTheme.orange,
          ),
          const SizedBox(width: 10),
          Text(
            validated
                ? 'Batch validé'
                : completed == 0
                ? 'Batch non validé'
                : 'En cours • $completed/$total terminées',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TrainingTile extends StatelessWidget {
  const _TrainingTile({
    required this.trainingId,
    required this.training,
    required this.progress,
    required this.batchId,
    required this.batchName,
  });

  final String trainingId;
  final Map<String, dynamic> training;
  final Map<String, dynamic>? progress;
  final String batchId;
  final String batchName;

  Future<void> _start(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseService().startTraining(
        uid: uid,
        trainingId: trainingId,
        title: training['title']?.toString() ?? 'Formation',
        batchId: batchId,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Formation démarrée.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de démarrer la formation : $error'),
          ),
        );
      }
    }
  }

  Future<void> _evaluate(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final score = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Évaluation de la formation'),
        content: const Text(
          'Confirmez-vous avoir compris les consignes et savoir les appliquer sur le terrain ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 0),
            child: const Text('Pas encore'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 100),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
    if (score != 100) return;
    final finalScore = score!;
    try {
      await FirebaseService().completeTraining(
        uid: uid,
        trainingId: trainingId,
        batchId: batchId,
        batchName: batchName,
        score: finalScore,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Formation validée.')));
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Évaluation impossible : $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = progress?['status']?.toString();
    final completed = status == 'completed';
    final started = status == 'started';
    return Card(
      margin: const EdgeInsets.only(top: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.school_outlined, color: AppTheme.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    training['title']?.toString() ?? 'Formation',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  completed
                      ? 'Validée'
                      : started
                      ? 'En cours'
                      : 'À faire',
                  style: TextStyle(
                    color: completed ? AppTheme.green : Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(training['description']?.toString() ?? ''),
            const SizedBox(height: 8),
            if (!completed)
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () =>
                      started ? _evaluate(context) : _start(context),
                  child: Text(started ? 'Passer l’évaluation' : 'Commencer'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
