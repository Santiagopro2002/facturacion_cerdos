import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../models/venta_models.dart';
import '../../repositories/venta_repository.dart';
import '../../settings/app_theme.dart';

class VentaScreen extends StatefulWidget {
  const VentaScreen({super.key});

  @override
  State<VentaScreen> createState() => _VentaScreenState();
}

class _VentaScreenState extends State<VentaScreen> {
  final repo = VentaRepository();
  List<VentaModels> lista = [];
  double total = 0;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    lista = await repo.getAll();
    total = await repo.totalVentas();
    cargando = false;
    if (mounted) setState(() {});
  }

  void dlgOk(String title, String desc) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkColor: AppColors.primary,
      btnOkText: 'Listo',
      btnOkOnPress: () {},
    ).show();
  }

  void dlgError(String title, String desc) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnOkColor: AppColors.primary,
      btnOkText: 'Entendido',
      btnOkOnPress: () {},
    ).show();
  }

  void dlgConfirm({
    required String title,
    required String desc,
    required VoidCallback onOk,
  }) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.question,
      animType: AnimType.scale,
      title: title,
      desc: desc,
      btnCancelText: 'Cancelar',
      btnOkText: 'Sí, eliminar',
      btnCancelOnPress: () {},
      btnOkColor: AppColors.danger,
      btnOkOnPress: onOk,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ventas')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargar,
              child: lista.isEmpty ? estadoVacio() : listadoVentas(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/ventas/form');
          cargar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva venta'),
      ),
      bottomNavigationBar: AppNav.bottomMenu(2, context),
    );
  }

  Widget estadoVacio() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        resumenTotal(),
        const SizedBox(height: 80),
        const Icon(Icons.point_of_sale, size: 80, color: AppColors.textSoft),
        const SizedBox(height: 15),
        const Text(
          'Aún no registras ventas',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Presiona “Nueva venta” para guardar cliente, producto y precio.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSoft),
        ),
      ],
    );
  }

  Widget listadoVentas() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: lista.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return resumenTotal();

        final item = lista[i - 1];
        return Card(
          color: Colors.white,
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.sell, color: AppColors.success),
            ),
            title: Text(
              item.cliente,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text('${item.producto}\nFecha: ${item.fecha}'),
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(item.precio),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () async {
                        await Navigator.pushNamed(context, '/ventas/form', arguments: item);
                        cargar();
                      },
                      child: const Icon(Icons.edit, color: AppColors.warning, size: 22),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        dlgConfirm(
                          title: 'Confirmar',
                          desc: '¿Deseas eliminar esta venta?',
                          onOk: () async {
                            try {
                              await repo.delete(item.id!);
                              await cargar();
                              if (!mounted) return;
                              dlgOk('Listo', 'Venta eliminada correctamente.');
                            } catch (e) {
                              if (!mounted) return;
                              dlgError('Error', e.toString());
                            }
                          },
                        );
                      },
                      child: const Icon(Icons.delete, color: AppColors.danger, size: 22),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget resumenTotal() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.success,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withAlpha(45),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.payments, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total vendido', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  money(total),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
