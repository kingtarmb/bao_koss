// JOSTAR BINARY SIGNATURE: 01001010 01001111 01010011 01010100 01000001 01010010

import 'package:flutter/material.dart';
import '../../features/auth/splash_page.dart';
import '../../features/auth/login_page.dart';
import '../../features/auth/register_page.dart';
import '../../features/dashboard/home_page.dart';
import '../../features/missions/missions_page.dart';
import '../../features/missions/mission_detail_page.dart';
import '../../features/gps/attendance_page.dart';
import '../../features/gps/checkout_page.dart';
import '../../features/payments/payments_page.dart';
import '../../features/badges/badges_page.dart';
import '../../features/incidents/incident_page.dart';
import '../../features/workers/workers_page.dart';
import '../../features/farmers/farmers_page.dart';
import '../../features/cpa/cpa_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/profile/edit_profile_page.dart';
import '../../features/training/trainings_page.dart';
import '../../features/admin/admin_dashboard_page.dart';
import '../../features/notifications/notifications_page.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const missions = '/missions';
  static const missionDetail = '/mission-detail';
  static const checkin = '/checkin';
  static const checkout = '/checkout';
  static const payments = '/payments';
  static const cpa = '/cpa';
  static const badges = '/badges';
  static const incident = '/incident';
  static const workers = '/workers';
  static const farmers = '/farmers';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const trainings = '/trainings';
  static const admin = '/admin';
  static const notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case missions:
        return MaterialPageRoute(builder: (_) => const MissionsPage());
      case missionDetail:
        return MaterialPageRoute(builder: (_) => const MissionDetailPage());
      case checkin:
        return MaterialPageRoute(builder: (_) => const AttendancePage());
      case checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutPage());
      case payments:
        return MaterialPageRoute(builder: (_) => const PaymentsPage());
      case cpa:
        return MaterialPageRoute(builder: (_) => const CpaPage());
      case badges:
        return MaterialPageRoute(builder: (_) => const BadgesPage());
      case incident:
        return MaterialPageRoute(builder: (_) => const IncidentPage());
      case workers:
        return MaterialPageRoute(builder: (_) => const WorkersPage());
      case farmers:
        return MaterialPageRoute(builder: (_) => const FarmersPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfilePage());
      case trainings:
        return MaterialPageRoute(builder: (_) => const TrainingsPage());
      case admin:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
