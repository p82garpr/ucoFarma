import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/domain/services/notification_service.dart';
import 'src/presentation/providers/auth_provider.dart';
import 'src/presentation/providers/medicine_provider.dart';
//import 'src/presentation/pages/login_page.dart';
import 'src/presentation/providers/shoplist_provider.dart';
import 'src/presentation/providers/dose_provider.dart';
import 'src/presentation/providers/chat_provider.dart';
import 'src/app.dart';
import 'src/presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationService = NotificationService();
  await notificationService.init();
  
  final authProvider = AuthProvider();
  final isAuthenticated = await authProvider.checkAuthStatus();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => authProvider),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => ShoplistProvider()),
        ChangeNotifierProvider(create: (_) => DoseProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: MyApp(isAuthenticated: isAuthenticated),
    ),
  );
}


/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uco Farma',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}
*/
