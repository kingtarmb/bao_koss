// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/local_database.dart';

class SyncService {
  final LocalDatabase local;
  final FirebaseFirestore firestore;

  SyncService({
    LocalDatabase? local,
    FirebaseFirestore? firestore,
  }) : local = local ?? LocalDatabase.instance,
       firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> enqueue(String entity, String action, Map<String, dynamic> payload) {
    return local.queueSync(entity, action, jsonEncode(payload));
  }

  Future<int> synchronize() async {
    final pending = await local.pendingSync();
    var count = 0;
    for (final item in pending) {
      final entity = item['entity'] as String;
      final payload = jsonDecode(item['payload'] as String) as Map<String, dynamic>;
      final docId = payload['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString();
      await firestore.collection(entity).doc(docId).set(payload, SetOptions(merge: true));
      await local.deleteSync(item['id'] as int);
      count++;
    }
    return count;
  }
}
