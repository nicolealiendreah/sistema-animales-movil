class Transfer {
  final String? id;
  final String nombreAnimal;
  final String? ubicacionAnterior;
  final String? ubicacionNueva;
  final String? motivo;
  final String? observaciones;
  final String? responsable;
  final DateTime fechaTraslado;

  Transfer({
    this.id,
    required this.nombreAnimal,
    this.ubicacionAnterior,
    this.ubicacionNueva,
    this.motivo,
    this.observaciones,
    this.responsable,
    required this.fechaTraslado,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] ?? json['_id'],
      nombreAnimal: json['nombreAnimal'] ?? '',
      ubicacionAnterior: json['ubicacionAnterior'],
      ubicacionNueva: json['ubicacionNueva'],
      motivo: json['motivo'],
      observaciones: json['observaciones'],
      responsable: json['responsable'],
      fechaTraslado: DateTime.parse(json['fechaTraslado']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'ubicacionAnterior': ubicacionAnterior,
      'ubicacionNueva': ubicacionNueva,
      'motivo': motivo,
      'observaciones': observaciones,
      'responsable': responsable,
      'fechaTraslado': fechaTraslado.toIso8601String(),
    };
  }
}
