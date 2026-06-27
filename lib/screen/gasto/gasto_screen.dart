import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../models/gasto_models.dart';
import '../../repositories/gasto_repository.dart';
import '../../settings/app_theme.dart';

class GastoScreen extends StatefulWidget {
  const GastoScreen({super.key});

  @override
  State<GastoScreen> createState() => _GastoScreenState();
}

class _GastoScreenState extends State<GastoScreen> {
  final repo = GastoRepository();
  List<GastoModels> lista = [];
  double total = 0;
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  Future<void> cargar() async {
    lista = await repo.getAll();
    total = await repo.totalGastos();
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
      appBar: AppBar(title: const Text('Gastos')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: cargar,
              child: lista.isEmpty ? estadoVacio() : listadoGastos(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, '/gastos/form');
          cargar();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo gasto'),
      ),
      bottomNavigationBar: AppNav.bottomMenu(1, context),
    );
  }

  Widget estadoVacio() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        resumenTotal(),
        const SizedBox(height: 80),
        const Icon(Icons.receipt_long, size: 80, color: AppColors.textSoft),
        const SizedBox(height: 15),
        const Text(
          'Aún no registras gastos',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Presiona “Nuevo gasto” para ingresar lechón, comida, vitaminas u otros.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSoft),
        ),
      ],
    );
  }

  Widget listadoGastos() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: lista.length + 1,
      itemBuilder: (_, i) {
        if (i == 0) return resumenTotal();

        final item = lista[i - 1];
        final detalle = item.detalle.trim().isEmpty ? 'Sin detalle' : item.detalle;

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
                color: AppColors.warning.withAlpha(30),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.shopping_cart, color: AppColors.warning),
            ),
            title: Text(
              item.tipo,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text('$detalle\nFecha: ${item.fecha}'),
            ),
            isThreeLine: true,
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  money(item.precio),
                  style: const TextStyle(
                    color: AppColors.danger,
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
                        await Navigator.pushNamed(context, '/gastos/form', arguments: item);
                        cargar();
                      },
                      child: const Icon(Icons.edit, color: AppColors.warning, size: 22),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        dlgConfirm(
                          title: 'Confirmar',
                          desc: '¿Deseas eliminar este gasto?',
                          onOk: () async {
                            try {
                              await repo.delete(item.id!);
                              await cargar();
                              if (!mounted) return;
                              dlgOk('Listo', 'Gasto eliminado correctamente.');
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
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(45),
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
            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total invertido', style: TextStyle(color: Colors.white70)),
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
