import 'package:flutter/material.dart';
import 'package:uco_farma/src/presentation/pages/add_medicine_manual_page.dart';
import 'package:uco_farma/src/presentation/pages/login_page.dart';
import 'package:uco_farma/src/presentation/pages/medicine_info_page.dart';
import 'package:uco_farma/src/presentation/pages/register_page.dart';
import 'package:uco_farma/src/presentation/pages/home_page.dart';
import 'package:uco_farma/src/presentation/pages/add_medicine_qr_page.dart';
import 'package:uco_farma/src/presentation/pages/add_medicine_nfc_page.dart';
import 'package:uco_farma/src/presentation/pages/profile_page.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';
  static const String register = '/register';
  static const String addMedicineManual = '/add-medicine-manual';
  static const String addMedicineQr = '/add-medicine-qr';
  static const String addMedicineNfc = '/add-medicine-nfc';
  static const String medicineInfo = '/medicine-info';
  static const String profile = '/profile';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const LoginPage(),
        home: (context) => const HomePage(),
        register: (context) => const RegisterPage(),
        addMedicineManual: (context) => const AddMedicineManualPage(),
        addMedicineQr: (context) => const AddMedicineQRPage(),
        addMedicineNfc: (context) => const AddMedicineNFCPage(),
        medicineInfo: (context) => const MedicineInfoPage(),
        profile: (context) => const ProfilePage(),

      };
}
