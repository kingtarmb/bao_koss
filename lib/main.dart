// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';

import 'core/app.dart';
import 'core/firebase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseBootstrap.initialize();

  runApp(const BaoKossApp());
}