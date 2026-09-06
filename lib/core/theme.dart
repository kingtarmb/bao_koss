// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:flutter/material.dart';
class AppTheme {
 static const green=Color(0xFF137A2A); static const orange=Color(0xFFEF7413);
 static ThemeData get light=>ThemeData(useMaterial3:true,scaffoldBackgroundColor:const Color(0xFFF5F7F4),colorScheme:ColorScheme.fromSeed(seedColor:green,primary:green,secondary:orange),appBarTheme:const AppBarTheme(backgroundColor:green,foregroundColor:Colors.white),cardTheme:const CardThemeData(elevation:1));
}
