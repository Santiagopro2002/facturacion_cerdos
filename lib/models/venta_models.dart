class VentaModels {
  int? id;
  String cliente;
  String producto;
  String fecha;
  double precio;

  VentaModels({
    this.id,
    required this.cliente,
    required this.producto,
    required this.fecha,
    required this.precio,
  });

  factory VentaModels.fromMap(Map<String, dynamic> data) {
    return VentaModels(
      id: data['id'],
      cliente: data['cliente'],
      producto: data['producto'],
      fecha: data['fecha'],
      precio: (data['precio'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cliente': cliente,
      'producto': producto,
      'fecha': fecha,
      'precio': precio,
    };
  }
}
