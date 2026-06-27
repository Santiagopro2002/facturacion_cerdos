import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0F3D3E);
  static const Color primaryDark = Color(0xFF092526);
  static const Color accent = Color(0xFFD9A441);
  static const Color background = Color(0xFFF4F7F6);
  static const Color card = Colors.white;
  static const Color success = Color(0xFF1B8A5A);
  static const Color danger = Color(0xFFC0392B);
  static const Color warning = Color(0xFFE67E22);
  static const Color textDark = Color(0xFF1F2933);
  static const Color textSoft = Color(0xFF6B7280);
}

class AppNav {
  static void onBottomNavTap(BuildContext context, int index) {
    final rutas = ['/', '/gastos', '/ventas', '/dashboard'];
    final rutaActual = ModalRoute.of(context)?.settings.name;

    if (rutaActual == rutas[index]) return;
    Navigator.pushNamedAndRemoveUntil(context, rutas[index], (route) => false);
  }

  static BottomNavigationBar bottomMenu(int currentIndex, BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) => onBottomNavTap(context, i),
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey.shade600,
      backgroundColor: Colors.white,
      elevation: 12,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Gastos'),
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Ventas'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Resumen'),
      ],
    );
  }
}

InputDecoration inputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.7),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.danger),
    ),
  );
}

String money(double value) {
  return '\$${value.toStringAsFixed(2)}';
}
