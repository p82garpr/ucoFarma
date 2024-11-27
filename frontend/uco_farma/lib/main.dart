import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/presentation/providers/auth_provider.dart';
import 'src/presentation/providers/medicine_provider.dart';
//import 'src/presentation/pages/login_page.dart';
import 'src/presentation/providers/shoplist_provider.dart';
import 'src/presentation/providers/dose_provider.dart';
import 'src/app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => ShoplistProvider()),
        ChangeNotifierProvider(create: (_) => DoseProvider()),
      ],
      child: const MyApp(),
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
