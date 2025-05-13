class Rescuer {
  final String? id;
  final String nombre;
  final String telefono;
  final DateTime fechaRescatista;
  final String ubicacionRescatista;

  Rescuer({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.fechaRescatista,
    required this.ubicacionRescatista,
  });

  factory Rescuer.fromJson(Map<String, dynamic> json) {
    return Rescuer(
      id: json['id']?.toString() ?? json['_id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      fechaRescatista: DateTime.parse(json['fechaRescatista']),
      ubicacionRescatista: json['ubicacionRescatista'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'fechaRescatista': fechaRescatista.toIso8601String(),
      'ubicacionRescatista': ubicacionRescatista,
    };
  }
}
