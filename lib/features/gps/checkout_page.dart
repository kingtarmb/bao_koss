// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/location/location_service.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/firebase_service.dart';
import '../../shared/widgets/page_header.dart';
import 'location_preview.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final comment = TextEditingController();
  bool loading = false;
  bool done = false;
  bool completeMission = true;
  XFile? photo;
  Position? position;
  bool locating = true;
  String placeName = 'Lieu en cours de détection';
  String message = 'Confirmez la fin de votre mission.';

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    try {
      final value = await LocationService().currentPosition();
      if (mounted) setState(() => position = value);
      unawaited(_loadPlaceName(value));
    } catch (_) {
      // The submit action retries the GPS lookup and displays the error.
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  Future<void> _loadPlaceName(Position value) async {
    try {
      final places = await Geocoding().placemarkFromCoordinates(
        value.latitude,
        value.longitude,
      );
      if (!mounted || places.isEmpty) return;
      final place = places.first;
      final parts = [place.name, place.locality, place.country]
          .where((part) => part != null && part.trim().isNotEmpty)
          .map((part) => part!.trim());
      final name = parts.join(', ');
      if (name.isNotEmpty) setState(() => placeName = name);
    } catch (_) {
      if (mounted) setState(() => placeName = 'Position GPS détectée');
    }
  }

  Future<void> takePhoto() async {
    final p = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (mounted && p != null) setState(() => photo = p);
  }

  Future<void> checkOut(String? missionId) async {
    setState(() => loading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Utilisateur non connecté.');

      final pos = position ?? await LocationService().currentPosition();
      final service = FirebaseService();

      String? storagePath;
      if (photo != null) {
        storagePath =
            'attendance/$uid/${DateTime.now().millisecondsSinceEpoch}_checkout.jpg';
      }

      final docId = await service.addAttendance({
        'userId': uid,
        'missionId': missionId,
        'type': 'checkout',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'comment': comment.text.trim(),
        'photoUrl': null,
        'photoPending': storagePath != null,
        'photoStoragePath': storagePath,
      });

      var photoSentNow = true;
      if (photo != null && storagePath != null) {
        photoSentNow = false;
        try {
          final bytes = await photo!.readAsBytes();
          final fileRef = FirebaseStorage.instance.ref(storagePath);
          await fileRef.putData(
            bytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          final photoUrl = await fileRef.getDownloadURL();
          await service.attendance.doc(docId).set({
            'photoUrl': photoUrl,
            'photoPending': false,
          }, SetOptions(merge: true));
          photoSentNow = true;
        } catch (_) {
          await SyncService().enqueuePhotoUpload(
            attendanceDocId: docId,
            localFilePath: photo!.path,
            storagePath: storagePath,
          );
        }
      }

      if (missionId != null && missionId.isNotEmpty) {
        try {
          await service.recordMissionCheckpoint(
            missionId: missionId,
            workerId: uid,
            type: 'checkout',
            completeMission: completeMission,
          );
        } catch (_) {
          await SyncService().enqueue('mission_checkpoint', 'record', {
            'missionId': missionId,
            'workerId': uid,
            'type': 'checkout',
            'completeMission': completeMission,
          });
        }
      }

      if (!mounted) return;
      setState(() {
        done = true;
        message = photoSentNow
            ? completeMission
                  ? 'Check-out enregistré. En attente de validation par l’agriculteur.'
                  : 'Check-out enregistré. Vous pouvez reprendre le travail avec un nouveau check-in.'
            : 'Check-out enregistré hors-ligne. La photo sera envoyée dès que la connexion reviendra.';
      });
    } catch (e) {
      if (mounted) setState(() => message = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missionId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Check-out'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Mission terminée ?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  LocationPreview(
                    loading: locating,
                    latitude: position?.latitude,
                    longitude: position?.longitude,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    position == null
                        ? 'Précision GPS : en attente...'
                        : 'Précision GPS : ${position!.accuracy.toStringAsFixed(0)} m',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  Text(
                    placeName,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  if (position != null)
                    Text(
                      '${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: loading || done ? null : takePhoto,
                    child: Container(
                      height: 164,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              photo == null
                                  ? Icons.image_outlined
                                  : Icons.photo_camera,
                              color: Colors.black54,
                              size: 42,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              photo == null
                                  ? 'Ajouter une photo'
                                  : 'Photo prête',
                              style: const TextStyle(color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (!done)
                    TextButton.icon(
                      onPressed: loading ? null : takePhoto,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        photo == null
                            ? 'Ajouter une photo (optionnel)'
                            : 'Reprendre la photo',
                      ),
                    ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: comment,
                    enabled: !loading && !done,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Commentaire (optionnel)',
                      hintText: 'Écrire un commentaire...',
                    ),
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: loading || done
                        ? null
                        : () => checkOut(missionId),
                    child: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            done ? 'Check-out validé' : 'Valider le check-out',
                          ),
                  ),
                  if (done) ...[
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: () =>
                          Navigator.of(context).popUntil((r) => r.isFirst),
                      child: const Text('Retour à l’accueil'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
