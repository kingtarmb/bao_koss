// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../shared/master_data.dart';

class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  FirebaseService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : auth = auth ?? FirebaseAuth.instance,
      firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => auth.currentUser;

  Future<UserCredential> signInEmail(String email, String password) =>
      auth.signInWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> registerEmail(String email, String password) =>
      auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> sendPasswordReset(String email) =>
      auth.sendPasswordResetEmail(email: email);

  Future<void> saveUserProfile(String uid, Map<String, dynamic> data) =>
      firestore.collection('users').doc(uid).set(data, SetOptions(merge: true));

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String uid) =>
      firestore.collection('users').doc(uid).get();

  Stream<DocumentSnapshot<Map<String, dynamic>>> userProfile(String uid) =>
      firestore.collection('users').doc(uid).snapshots();

  Future<void> signOut() => auth.signOut();

  CollectionReference<Map<String, dynamic>> get missions =>
      firestore.collection('missions');

  CollectionReference<Map<String, dynamic>> get payments =>
      firestore.collection('payments');

  CollectionReference<Map<String, dynamic>> get batches =>
      firestore.collection('batches');

  CollectionReference<Map<String, dynamic>> get trainings =>
      firestore.collection('trainings');

  CollectionReference<Map<String, dynamic>> get trainingProgress =>
      firestore.collection('trainingProgress');

  CollectionReference<Map<String, dynamic>> get evaluations =>
      firestore.collection('evaluations');

  CollectionReference<Map<String, dynamic>> get badges =>
      firestore.collection('badges');

  CollectionReference<Map<String, dynamic>> get attendance =>
      firestore.collection('attendance');

  Future<String> createMission(Map<String, dynamic> data) async {
    final ref = missions.doc();
    await ref.set({
      ...data,
      'id': ref.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> ensureDemoMissions(String farmerId, String ownerName) async {
    final examples = [
      {
        'id': 'demo-mission-semis',
        'title': 'Semis de maïs',
        'description': 'Préparer la parcelle et réaliser les semis de maïs.',
        'location': 'Village de démonstration',
        'budget': 15000,
      },
      {
        'id': 'demo-mission-recolte',
        'title': 'Récolte maraîchère',
        'description': 'Récolter, trier et conditionner les légumes du jour.',
        'location': 'Périmètre agricole de démonstration',
        'budget': 12000,
      },
    ];

    for (final example in examples) {
      final missionId = 'demo-$farmerId-${example['id']}';
      final ref = missions.doc(missionId);
      if ((await ref.get()).exists) continue;
      await ref.set({
        ...example,
        'id': missionId,
        'farmerId': farmerId,
        'ownerName': ownerName,
        'workerId': null,
        'status': 'published',
        'date': DateTime.now().toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> ensureDemoData(String uid, {String? name}) async {
    final profileRef = firestore.collection('users').doc(uid);
    await profileRef.set({
      'uid': uid,
      'name': name?.trim().isNotEmpty == true ? name!.trim() : 'Kossi Démo',
      'role': 'employe',
      'village': 'Daloa',
      'canton': 'Centre',
      'subPrefecture': 'Daloa',
      'department': 'Haut-Sassandra',
      'cpaNumber': 'CPA-00-0015254',
      'demoData': true,
    }, SetOptions(merge: true));

    await ensureDemoMissions(uid, name ?? 'Agriculteur de test');

    final badgeRef = profileRef.collection('badges').doc('batch-recolte');
    await badgeRef.set({
      'name': 'Récolte',
      'batchId': 'batch-recolte',
      'status': 'validated',
      'score': 92,
      'certifiedAt': '15/05/2026',
    }, SetOptions(merge: true));
  }

  Future<void> updateMission(String id, Map<String, dynamic> data) =>
      missions.doc(id).set(data, SetOptions(merge: true));

  Future<void> ensureMasterData() async {
    final batchWrites = defaultBatches.map((batch) async {
      final ref = batches.doc(batch.id);
      final payload = batch.toFirestore();
      await ref.set(payload, SetOptions(merge: true));
    });

    final trainingWrites = defaultTrainings.map((training) async {
      final ref = trainings.doc(training.id);
      final payload = training.toFirestore();
      await ref.set(payload, SetOptions(merge: true));
    });

    await Future.wait([...batchWrites, ...trainingWrites]);
  }

  Future<void> assignUserBatch(String uid, String batchId) async {
    await firestore.collection('users').doc(uid).set({
      'batchId': batchId,
      'batchUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> startTraining({
    required String uid,
    required String trainingId,
    required String title,
    required String batchId,
  }) async {
    final ref = firestore
        .collection('users')
        .doc(uid)
        .collection('trainingProgress')
        .doc(trainingId);

    await ref.set({
      'trainingId': trainingId,
      'batchId': batchId,
      'title': title,
      'status': 'started',
      'startedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> completeTraining({
    required String uid,
    required String trainingId,
    required String batchId,
    required String batchName,
    required int score,
  }) async {
    final ref = firestore
        .collection('users')
        .doc(uid)
        .collection('trainingProgress')
        .doc(trainingId);

    await ref.set({
      'trainingId': trainingId,
      'batchId': batchId,
      'status': 'completed',
      'score': score,
      'completedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    final requiredTrainings = await trainings
        .where('batchId', isEqualTo: batchId)
        .where('active', isEqualTo: true)
        .get();
    final completedTrainings = await firestore
        .collection('users')
        .doc(uid)
        .collection('trainingProgress')
        .where('batchId', isEqualTo: batchId)
        .where('status', isEqualTo: 'completed')
        .get();

    if (requiredTrainings.docs.isNotEmpty &&
        completedTrainings.docs.length >= requiredTrainings.docs.length) {
      await firestore
          .collection('users')
          .doc(uid)
          .collection('badges')
          .doc(batchId)
          .set({
            'name': batchName,
            'batchId': batchId,
            'status': 'validated',
            'validatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    }
  }

  Future<bool> acceptMissionTransactional({
    required String missionId,
    required String workerId,
    String? workerEmail,
  }) {
    final missionRef = missions.doc(missionId);
    return firestore.runTransaction<bool>((tx) async {
      final snap = await tx.get(missionRef);
      if (!snap.exists) {
        throw Exception('Cette mission n’existe plus.');
      }
      final data = snap.data() ?? {};
      final existingWorker = data['workerId'] as String?;
      if (existingWorker != null &&
          existingWorker.isNotEmpty &&
          existingWorker != workerId) {
        return false;
      }
      tx.set(missionRef, {
        'workerId': workerId,
        'workerEmail': workerEmail,
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return true;
    });
  }

  Future<void> updateMissionStatus(String missionId, String status) {
    final fieldByStatus = {
      'in_progress': 'checkinAt',
      'completed': 'checkoutAt',
      'validated': 'validatedAt',
    };
    final extraField = fieldByStatus[status];
    return missions.doc(missionId).set({
      'status': status,
      ...(extraField != null ? {extraField: FieldValue.serverTimestamp()} : {}),
    }, SetOptions(merge: true));
  }

  Future<void> recordMissionCheckpoint({
    required String missionId,
    required String workerId,
    required String type,
    bool completeMission = true,
  }) async {
    final mission = await missions.doc(missionId).get();
    final data = mission.data() ?? {};
    if (data['workerId'] != workerId) {
      throw Exception('Cette mission n’est pas affectée à cet utilisateur.');
    }
    await missions.doc(missionId).set({
      'status': type == 'checkin'
          ? 'in_progress'
          : completeMission
          ? 'completed'
          : 'accepted',
      if (type == 'checkin') 'checkinAt': FieldValue.serverTimestamp(),
      if (type == 'checkout' && completeMission)
        'checkoutAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<String> addAttendance(Map<String, dynamic> data) async {
    final ref = attendance.doc();
    await ref.set({
      ...data,
      'id': ref.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }
}
