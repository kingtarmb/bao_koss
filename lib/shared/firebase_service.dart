// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  FirebaseService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance;
  User? get currentUser => auth.currentUser;
  Future<UserCredential> signInEmail(String email, String password) => auth.signInWithEmailAndPassword(email: email, password: password);
  Future<UserCredential> registerEmail(String email, String password) => auth.createUserWithEmailAndPassword(email: email, password: password);
  Future<void> sendPasswordReset(String email) => auth.sendPasswordResetEmail(email: email);
  Future<void> saveUserProfile(String uid, Map<String,dynamic> data) => firestore.collection('users').doc(uid).set(data, SetOptions(merge:true));
  Stream<DocumentSnapshot<Map<String,dynamic>>> userProfile(String uid) => firestore.collection('users').doc(uid).snapshots();
  Future<void> signOut() => auth.signOut();
  CollectionReference<Map<String,dynamic>> get missions => firestore.collection('missions');
  CollectionReference<Map<String,dynamic>> get payments => firestore.collection('payments');
  CollectionReference<Map<String,dynamic>> get trainings => firestore.collection('trainings');
  CollectionReference<Map<String,dynamic>> get evaluations => firestore.collection('evaluations');
  CollectionReference<Map<String,dynamic>> get badges => firestore.collection('badges');
  Future<String> createMission(Map<String,dynamic> data) async { final ref=missions.doc(); await ref.set({...data,'id':ref.id,'createdAt':FieldValue.serverTimestamp()}); return ref.id; }
  Future<void> updateMission(String id, Map<String,dynamic> data) => missions.doc(id).set(data,SetOptions(merge:true));
}
