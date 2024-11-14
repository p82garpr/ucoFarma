
import 'package:flutter/material.dart';
import 'package:uco_farma/src/app_routes.dart';
import 'package:uco_farma/src/config/theme/app_theme.dart';



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uco Farma',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: ThemeData(
        colorScheme: AppTheme().theme().colorScheme,
        useMaterial3: true,
      ),
      //home: const LoginPage(),
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
    );
  }

}