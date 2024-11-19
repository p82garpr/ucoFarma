import 'package:flutter/material.dart';
import 'package:uco_farma/src/app_routes.dart';
import 'package:uco_farma/src/config/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Añadir esta línea


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uco Farma',
      debugShowCheckedModeBanner: false, // Remove the debug banner
      theme: AppTheme().theme(),
      //home: const LoginPage(),
      initialRoute: AppRoutes.initial,
      routes: AppRoutes.routes,
      //Para los idiomas de las localizaciones
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'), // Español de España
      ],
    );
  }
}
