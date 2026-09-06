// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010
import 'package:flutter/material.dart';
import '../features/auth/login_page.dart';
import '../features/dashboard/home_page.dart';
import '../features/missions/missions_page.dart';
import '../features/workers/workers_page.dart';
import '../features/farmers/farmers_page.dart';
import '../features/cpa/cpa_page.dart';
import '../features/payments/payments_page.dart';
import '../features/badges/badges_page.dart';
import '../features/gps/attendance_page.dart';
import '../features/incidents/incidents_page.dart';

class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const missions = '/missions';
  static const workers = '/workers';
  static const farmers = '/farmers';
  static const cpa = '/cpa';
  static const payments = '/payments';
  static const badges = '/badges';
  static const attendance = '/attendance';
  static const incidents = '/incidents';

  static final Map<String, WidgetBuilder> map = {
    home: (_) => const HomePage(),
    login: (_) => const LoginPage(),
    missions: (_) => const MissionsPage(),
    workers: (_) => const WorkersPage(),
    farmers: (_) => const FarmersPage(),
    cpa: (_) => const CpaPage(),
    payments: (_) => const PaymentsPage(),
    badges: (_) => const BadgesPage(),
    attendance: (_) => const AttendancePage(),
    incidents: (_) => const IncidentsPage(),
  };
}
