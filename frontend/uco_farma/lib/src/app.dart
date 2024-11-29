import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uco_farma/src/app_routes.dart';
import 'package:uco_farma/src/config/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:uco_farma/src/presentation/providers/theme_provider.dart';

class MyApp extends StatelessWidget {
  final bool isAuthenticated;
  
  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Uco Farma',
          debugShowCheckedModeBanner: false,
          theme: AppTheme().theme(),
          darkTheme: AppTheme().darkTheme(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: isAuthenticated ? AppRoutes.home : AppRoutes.initial,
          routes: AppRoutes.routes,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'ES'),
          ],
        );
      },
    );
  }
}
