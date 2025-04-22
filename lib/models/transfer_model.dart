class Transfer {
  final String? id;
  final String animalId;
  final String? ubicacionAnterior;
  final String? ubicacionNueva;
  final String? motivo;
  final String? observaciones;
  final String? responsable;
  final DateTime fechaTraslado;

  Transfer({
    this.id,
    required this.animalId,
    this.ubicacionAnterior,
    this.ubicacionNueva,
    this.motivo,
    this.observaciones,
    this.responsable,
    required this.fechaTraslado,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
  return Transfer(
    id: json['_id']?.toString(),
    animalId: json['animalId'].toString(),
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
      'animalId': animalId,
      'ubicacionAnterior': ubicacionAnterior,
      'ubicacionNueva': ubicacionNueva,
      'motivo': motivo,
      'observaciones': observaciones,
      'responsable': responsable,
      'fechaTraslado': fechaTraslado.toIso8601String(),
    };
  }
}
