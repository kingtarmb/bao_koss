// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../core/firebase_bootstrap.dart';
class NotificationService{static Future<void>initialize()async{if(!FirebaseBootstrap.available)return;final m=FirebaseMessaging.instance;await m.requestPermission(alert:true,badge:true,sound:true);await m.getToken();}}
