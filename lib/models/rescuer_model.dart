class Rescuer {
  final String? id;
  final String nombre;
  final String telefono;
  final DateTime fechaRescate;
  final String ubicacionRescate;

  Rescuer({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.fechaRescate,
    required this.ubicacionRescate,
  });

  factory Rescuer.fromJson(Map<String, dynamic> json) {
    return Rescuer(
      id: json['_id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      fechaRescate: DateTime.parse(json['fechaRescate']),
      ubicacionRescate: json['ubicacionRescate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'fechaRescate': fechaRescate.toIso8601String(),
      'ubicacionRescate': ubicacionRescate,
    };
  }
}
