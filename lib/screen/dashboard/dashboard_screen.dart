import 'package:flutter/material.dart';

import '../../repositories/gasto_repository.dart';
import '../../repositories/venta_repository.dart';
import '../../settings/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final gastoRepo = GastoRepository();
  final ventaRepo = VentaRepository();

  double totalGastos = 0;
  double totalVentas = 0;
  int cantidadGastos = 0;
  int cantidadVentas = 0;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargarResumen();
  }

  Future<void> cargarResumen() async {
    final gastos = await gastoRepo.getAll();
    final ventas = await ventaRepo.getAll();
    totalGastos = await gastoRepo.totalGastos();
    totalVentas = await ventaRepo.totalVentas();
    cantidadGastos = gastos.length;
    cantidadVentas = ventas.length;
    cargando = false;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final resultado = totalVentas - totalGastos;
    final hayGanancia = resultado >= 0;
    final colorResultado = hayGanancia ? AppColors.success : AppColors.danger;
    final textoResultado = hayGanancia ? 'GANANCIA' : 'PÉRDIDA';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Dashboard')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargarResumen,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 90),
                children: [
                  encabezado(resultado, colorResultado, textoResultado),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: tarjetaResumen(
                          titulo: 'Gastos',
                          valor: money(totalGastos),
                          detalle: '$cantidadGastos registros',
                          icono: Icons.trending_down,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: tarjetaResumen(
                          titulo: 'Ventas',
                          valor: money(totalVentas),
                          detalle: '$cantidadVentas registros',
                          icono: Icons.trending_up,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  tarjetaBalance(resultado, colorResultado, textoResultado),
                  const SizedBox(height: 18),
                  accionesRapidas(),
                  const SizedBox(height: 18),
                  consejo(resultado),
                ],
              ),
            ),
      bottomNavigationBar: AppNav.bottomMenu(3, context),
    );
  }

  Widget encabezado(double resultado, Color colorResultado, String textoResultado) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorResultado, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorResultado.withAlpha(55),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  resultado >= 0 ? Icons.emoji_events : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  textoResultado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Resultado actual',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            money(resultado.abs()),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            resultado >= 0
                ? 'Vas ganando según tus ventas y gastos registrados.'
                : 'Todavía falta vender más para recuperar la inversión.',
            style: const TextStyle(color: Colors.white70, height: 1.3),
          ),
        ],
      ),
    );
  }

  Widget tarjetaResumen({
    required String titulo,
    required String valor,
    required String detalle,
    required IconData icono,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icono, color: color, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            titulo,
            style: const TextStyle(color: AppColors.textSoft, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valor,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(detalle, style: const TextStyle(color: AppColors.textSoft, fontSize: 12)),
        ],
      ),
    );
  }

  Widget tarjetaBalance(double resultado, Color colorResultado, String textoResultado) {
    final recuperado = totalGastos <= 0 ? 0.0 : (totalVentas / totalGastos).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorResultado.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: colorResultado),
              const SizedBox(width: 8),
              const Text(
                'Análisis rápido',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(
            value: recuperado,
            minHeight: 10,
            borderRadius: BorderRadius.circular(20),
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(colorResultado),
          ),
          const SizedBox(height: 10),
          Text(
            totalGastos <= 0
                ? 'Registra gastos para calcular la inversión.'
                : 'Has recuperado aproximadamente ${(recuperado * 100).toStringAsFixed(0)}% de lo invertido.',
            style: const TextStyle(color: AppColors.textSoft, height: 1.3),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorResultado.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$textoResultado: ${money(resultado.abs())}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorResultado,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget accionesRapidas() {
    return Row(
      children: [
        Expanded(
          child: botonAccion(
            texto: 'Agregar gasto',
            icono: Icons.add_card,
            color: AppColors.warning,
            ruta: '/gastos/form',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: botonAccion(
            texto: 'Agregar venta',
            icono: Icons.add_shopping_cart,
            color: AppColors.success,
            ruta: '/ventas/form',
          ),
        ),
      ],
    );
  }

  Widget botonAccion({
    required String texto,
    required IconData icono,
    required Color color,
    required String ruta,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () async {
        await Navigator.pushNamed(context, ruta);
        cargarResumen();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(45),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icono, color: Colors.white, size: 28),
            const SizedBox(height: 8),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget consejo(double resultado) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.accent, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              resultado >= 0
                  ? 'Bien miso, ya estás arriba. Sigue registrando cada venta para no perder el control.'
                  : 'Todavía estás abajo, pero es normal si recién empiezas a vender. Registra todo para saber el punto exacto de recuperación.',
              style: const TextStyle(color: AppColors.textSoft, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}
