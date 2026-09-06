// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/location/location_service.dart';
import '../../shared/widgets/page_header.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});
  @override State<AttendancePage> createState() => _AttendancePageState();
}
class _AttendancePageState extends State<AttendancePage> {
  bool loading=false; XFile? photo;
  String message='Vérifiez votre position puis prenez la photo de présence.';

  Future<void> takePhoto() async {
    final p=await ImagePicker().pickImage(source:ImageSource.camera,imageQuality:85);
    if(mounted && p!=null) setState(()=>photo=p);
  }

  Future<void> checkIn() async {
    if(photo==null){ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Prenez d’abord une photo de présence.')));return;}
    setState(()=>loading=true);
    try {
      final pos=await LocationService().currentPosition();
      final uid=FirebaseAuth.instance.currentUser?.uid;
      if(uid==null) throw Exception('Utilisateur non connecté.');
      final bytes=await photo!.readAsBytes();
      final fileRef=FirebaseStorage.instance.ref('attendance/$uid/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await fileRef.putData(bytes,SettableMetadata(contentType:'image/jpeg'));
      final photoUrl=await fileRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('attendance').add({'userId':uid,'type':'checkin','latitude':pos.latitude,'longitude':pos.longitude,'accuracy':pos.accuracy,'photoUrl':photoUrl,'createdAt':FieldValue.serverTimestamp()});
      if(mounted)setState(()=>message='Présence enregistrée • précision ${pos.accuracy.toStringAsFixed(0)} m');
    } catch(e) { if(mounted)setState(()=>message='Erreur : $e'); }
    finally { if(mounted)setState(()=>loading=false); }
  }

  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Column(children:[const PageHeader(title:'Check-in'),Expanded(child:ListView(padding:const EdgeInsets.all(16),children:[Text(message,textAlign:TextAlign.center),const SizedBox(height:14),Container(height:210,decoration:BoxDecoration(color:Colors.grey.shade200,borderRadius:BorderRadius.circular(10)),child:Center(child:Icon(photo==null?Icons.location_on:Icons.photo_camera,size:54))),if(photo!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text('Photo : ${photo!.name}',textAlign:TextAlign.center)),const SizedBox(height:12),OutlinedButton.icon(onPressed:loading?null:takePhoto,icon:const Icon(Icons.camera_alt_outlined),label:Text(photo==null?'Prendre une photo':'Reprendre la photo')),const SizedBox(height:10),FilledButton(onPressed:loading?null:checkIn,child:loading?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):const Text('Valider le check-in'))]))])));
}
