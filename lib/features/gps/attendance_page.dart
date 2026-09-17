// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/location/location_service.dart';
import '../../core/routes/app_routes.dart';
import '../../core/sync/sync_service.dart';
import '../../shared/firebase_service.dart';
import '../../shared/widgets/page_header.dart';
import 'location_preview.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  bool loading = false;
  bool done = false;
  XFile? photo;
  Position? position;
  bool locating = true;
  String placeName = 'Lieu en cours de détection';
  String message = 'Vérifiez votre position puis prenez la photo de présence.';

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
      // The submit action retries the GPS lookup and shows the actual error.
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

  Future<void> checkIn(String? missionId) async {
    if (photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prenez d’abord une photo de présence.')),
      );
      return;
    }
    setState(() => loading = true);
    try {
      final pos = position ?? await LocationService().currentPosition();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Utilisateur non connecté.');

      final service = FirebaseService();

      // 1. On écrit d'abord le document de présence (fonctionne aussi
      //    hors-ligne : Firestore met la lecture/écriture en cache local et
      //    synchronise automatiquement dès que le réseau revient).
      final storagePath =
          'attendance/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final docId = await service.addAttendance({
        'userId': uid,
        'missionId': missionId,
        'type': 'checkin',
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'photoUrl': null,
        'photoPending': true,
        'photoStoragePath': storagePath,
      });

      // 2. On tente d'envoyer la photo tout de suite. Si le réseau manque,
      //    l'envoi de la photo (Firebase Storage) ne se met PAS en file
      //    automatiquement comme Firestore : on la met nous-mêmes en file
      //    via SyncService, qui réessaiera dès que possible.
      var photoSentNow = false;
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

      // 3. La mission passe "en cours" et le cycle est comptabilisé.
      if (missionId != null && missionId.isNotEmpty) {
        try {
          await service.recordMissionCheckpoint(
            missionId: missionId,
            workerId: uid,
            type: 'checkin',
          );
        } catch (_) {
          await SyncService().enqueue('mission_checkpoint', 'record', {
            'missionId': missionId,
            'workerId': uid,
            'type': 'checkin',
            'completeMission': false,
          });
        }
      }

      if (!mounted) return;
      setState(() {
        done = true;
        message = photoSentNow
            ? 'Check-in enregistré • précision ${pos.accuracy.toStringAsFixed(0)} m'
            : 'Présence enregistrée hors-ligne (précision ${pos.accuracy.toStringAsFixed(0)} m). '
                  'La photo sera envoyée automatiquement dès que la connexion reviendra.';
      });
    } catch (e) {
      if (mounted) setState(() => message = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final missionId = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const PageHeader(title: 'Check-in'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Vous êtes arrivé sur le lieu de la mission ?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
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
                  const SizedBox(height: 4),
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
                  if (photo != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Photo : ${photo!.name}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),
                  if (!done) ...[
                    OutlinedButton.icon(
                      onPressed: loading ? null : takePhoto,
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(
                        photo == null
                            ? 'Prendre une photo'
                            : 'Reprendre la photo',
                      ),
                    ),
                    const SizedBox(height: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      onPressed: loading ? null : () => checkIn(missionId),
                      child: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Valider le check-in'),
                    ),
                  ] else
                    FilledButton.icon(
                      onPressed: missionId == null
                          ? null
                          : () => Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.checkout,
                              arguments: missionId,
                            ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Faire le check-out'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
