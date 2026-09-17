// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../database/local_database.dart';

/// Moteur de synchronisation hors-ligne.
///
/// Les écritures Firestore "classiques" (missions, statuts, candidatures...)
/// sont déjà mises en file et rejouées automatiquement par le SDK Firestore
/// lui-même dès que le réseau revient (persistance activée dans
/// firebase_bootstrap.dart) : ce service n'a donc rien à faire pour elles.
///
/// En revanche, l'envoi d'une photo vers Firebase Storage n'est PAS mis en
/// file automatiquement par le SDK. C'est ce que ce service gère : si une
/// photo de check-in/check-out n'a pas pu être envoyée immédiatement, elle
/// est mise en file ici (entity: 'attendance_photo') puis réessayée par
/// [synchronize].
class SyncService {
  final LocalDatabase local;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  SyncService({
    LocalDatabase? local,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : local = local ?? LocalDatabase.instance,
       firestore = firestore ?? FirebaseFirestore.instance,
       storage = storage ?? FirebaseStorage.instance;

  /// Met en file une donnée générique à rejouer plus tard vers Firestore.
  Future<void> enqueue(
    String entity,
    String action,
    Map<String, dynamic> payload,
  ) {
    return local.queueSync(entity, action, jsonEncode(payload));
  }

  /// Met en file une photo de présence (check-in/check-out) dont l'envoi
  /// vers Firebase Storage a échoué faute de réseau.
  Future<void> enqueuePhotoUpload({
    required String attendanceDocId,
    required String localFilePath,
    required String storagePath,
  }) {
    return enqueue('attendance_photo', 'upload', {
      'attendanceDocId': attendanceDocId,
      'localFilePath': localFilePath,
      'storagePath': storagePath,
    });
  }

  /// Rejoue toute la file d'attente locale. Ne lève jamais d'exception :
  /// un échec (toujours pas de réseau) laisse simplement l'élément en file
  /// pour le prochain essai.
  Future<int> synchronize() async {
    final pending = await local.pendingSync();
    var count = 0;

    for (final item in pending) {
      final id = item['id'] as int;
      final entity = item['entity'] as String;
      final payload =
          jsonDecode(item['payload'] as String) as Map<String, dynamic>;

      try {
        if (entity == 'attendance_photo') {
          await _retryPhotoUpload(payload);
        } else if (entity == 'mission_checkpoint') {
          await _retryMissionCheckpoint(payload);
        } else {
          final docId =
              payload['id']?.toString() ??
              DateTime.now().microsecondsSinceEpoch.toString();
          await firestore
              .collection(entity)
              .doc(docId)
              .set(payload, SetOptions(merge: true));
        }
        await local.deleteSync(id);
        count++;
      } catch (_) {
        // Toujours pas de réseau (ou erreur transitoire) : on garde
        // l'élément en file et on réessaiera au prochain appel.
      }
    }

    return count;
  }

  /// Comme [synchronize] mais avale silencieusement toute erreur globale
  /// (utilisé pour les tentatives automatiques en arrière-plan).
  Future<void> trySyncSilently() async {
    try {
      await synchronize();
    } catch (_) {
      // Volontairement ignoré : nouvelle tentative au prochain déclenchement.
    }
  }

  Future<void> _retryPhotoUpload(Map<String, dynamic> payload) async {
    final attendanceDocId = payload['attendanceDocId'] as String;
    final localFilePath = payload['localFilePath'] as String;
    final storagePath = payload['storagePath'] as String;

    final file = File(localFilePath);
    if (!await file.exists()) {
      // Le fichier local n'existe plus (cache nettoyé par l'OS) : on
      // abandonne proprement cet envoi plutôt que de réessayer indéfiniment.
      return;
    }

    final ref = storage.ref(storagePath);
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    final photoUrl = await ref.getDownloadURL();

    await firestore.collection('attendance').doc(attendanceDocId).set({
      'photoUrl': photoUrl,
      'photoPending': false,
    }, SetOptions(merge: true));
  }

  Future<void> _retryMissionCheckpoint(Map<String, dynamic> payload) async {
    final missionRef = firestore
        .collection('missions')
        .doc(payload['missionId'] as String);
    final workerId = payload['workerId'] as String;
    final type = payload['type'] as String;
    final completeMission = payload['completeMission'] as bool? ?? false;

    await firestore.runTransaction<void>((tx) async {
      final snap = await tx.get(missionRef);
      final data = snap.data();
      if (!snap.exists || data == null || data['workerId'] != workerId) {
        throw Exception('Cette mission ne vous est pas attribuée.');
      }

      final isCheckIn = type == 'checkin';
      final countField = isCheckIn ? 'checkInCount' : 'checkOutCount';
      final currentCount = (data[countField] as num?)?.toInt() ?? 0;
      final nextStatus = isCheckIn
          ? 'in_progress'
          : (completeMission ? 'completed' : 'accepted');

      tx.set(missionRef, {
        countField: currentCount + 1,
        'status': nextStatus,
        '${type}At': FieldValue.serverTimestamp(),
        'lastProgressAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }
}
