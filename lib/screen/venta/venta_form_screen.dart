import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../models/venta_models.dart';
import '../../repositories/venta_repository.dart';
import '../../settings/app_theme.dart';

class VentaFormScreen extends StatefulWidget {
  const VentaFormScreen({super.key});

  @override
  State<VentaFormScreen> createState() => _VentaFormScreenState();
}

class _VentaFormScreenState extends State<VentaFormScreen> {
  final formKey = GlobalKey<FormState>();
  final clienteController = TextEditingController();
  final productoController = TextEditingController();
  final fechaController = TextEditingController();
  final precioController = TextEditingController();

  VentaModels? venta;
  bool _argsCargados = false;

  @override
  void initState() {
    super.initState();
    fechaController.text = fechaHoy();
  }

  @override
  void dispose() {
    clienteController.dispose();
    productoController.dispose();
    fechaController.dispose();
    precioController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsCargados) return;
    _argsCargados = true;

    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      venta = args as VentaModels;
      clienteController.text = venta!.cliente;
      productoController.text = venta!.producto;
      fechaController.text = venta!.fecha;
      precioController.text = venta!.precio.toStringAsFixed(2);
    }
  }

  String fechaHoy() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> seleccionarFecha() async {
    final now = DateTime.now();
    final seleccion = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 2),
      helpText: 'Selecciona la fecha de venta',
    );

    if (seleccion != null) {
      fechaController.text = '${seleccion.year}-${seleccion.month.toString().padLeft(2, '0')}-${seleccion.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  double parsePrecio(String value) {
    return double.parse(value.trim().replaceAll(',', '.'));
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
      btnOkOnPress: () {
        Navigator.pop(context, true);
      },
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
      btnOkText: 'Sí, guardar',
      btnCancelOnPress: () {},
      btnOkColor: AppColors.primary,
      btnOkOnPress: onOk,
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final esEditar = venta != null;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(esEditar ? 'Editar Venta' : 'Nueva Venta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              encabezado(esEditar),
              const SizedBox(height: 20),
              TextFormField(
                controller: clienteController,
                textCapitalization: TextCapitalization.words,
                decoration: inputDecoration('Nombre del cliente', Icons.person),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa el nombre del cliente';
                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                  if (v.trim().length > 60) return 'Máximo 60 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: productoController,
                textCapitalization: TextCapitalization.sentences,
                decoration: inputDecoration('¿Qué se vendió? Ej: pierna, carne pura, cabeza', Icons.inventory_2),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Escribe qué se vendió';
                  if (v.trim().length < 3) return 'Mínimo 3 caracteres';
                  if (v.trim().length > 80) return 'Máximo 80 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: fechaController,
                readOnly: true,
                onTap: seleccionarFecha,
                decoration: inputDecoration('Fecha de venta', Icons.calendar_month),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Selecciona una fecha' : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: precioController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: inputDecoration('Precio vendido', Icons.attach_money),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Ingresa el precio';
                  final precio = double.tryParse(v.trim().replaceAll(',', '.'));
                  if (precio == null) return 'Ingresa un número válido';
                  if (precio <= 0) return 'El precio debe ser mayor a 0';
                  if (precio > 100000) return 'Precio demasiado alto';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              botones(esEditar),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppNav.bottomMenu(2, context),
    );
  }

  Widget encabezado(bool esEditar) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(30),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(Icons.point_of_sale, color: AppColors.success, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              esEditar ? 'Actualiza la venta registrada' : 'Registra una nueva venta',
              style: const TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget botones(bool esEditar) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              dlgConfirm(
                title: 'Confirmar',
                desc: '¿Deseas guardar esta venta?',
                onOk: () async {
                  try {
                    final repo = VentaRepository();
                    final data = VentaModels(
                      cliente: clienteController.text.trim(),
                      producto: productoController.text.trim(),
                      fecha: fechaController.text.trim(),
                      precio: parsePrecio(precioController.text),
                    );

                    if (esEditar) {
                      data.id = venta!.id;
                      await repo.edit(data);
                    } else {
                      await repo.create(data);
                    }

                    if (!mounted) return;
                    dlgOk('Listo', 'Venta guardada correctamente.');
                  } catch (e) {
                    if (!mounted) return;
                    dlgError('Error', e.toString());
                  }
                },
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.close),
            label: const Text('Cancelar'),
          ),
        ),
      ],
    );
  }
}
