class GastoModels {
  int? id;
  String tipo;
  String detalle;
  String fecha;
  double precio;

  GastoModels({
    this.id,
    required this.tipo,
    required this.detalle,
    required this.fecha,
    required this.precio,
  });

  factory GastoModels.fromMap(Map<String, dynamic> data) {
    return GastoModels(
      id: data['id'],
      tipo: data['tipo'],
      detalle: data['detalle'] ?? '',
      fecha: data['fecha'],
      precio: (data['precio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo,
      'detalle': detalle,
      'fecha': fecha,
      'precio': precio,
    };
  }
}
