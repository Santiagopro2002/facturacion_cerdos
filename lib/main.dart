import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'screen/dashboard/dashboard_screen.dart';
import 'screen/gasto/gasto_form_screen.dart';
import 'screen/gasto/gasto_screen.dart';
import 'screen/venta/venta_form_screen.dart';
import 'screen/venta/venta_screen.dart';
import 'settings/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Facturación Cerdos',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/gastos': (context) => const GastoScreen(),
        '/gastos/form': (context) => const GastoFormScreen(),
        '/ventas': (context) => const VentaScreen(),
        '/ventas/form': (context) => const VentaFormScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
