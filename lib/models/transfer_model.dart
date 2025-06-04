class Transfer {
  final String? id;
  final String? animalId;
  final String nombreAnimal;
  final String? ubicacionAnterior;
  final String? motivo;
  final String? observaciones;
  final String? responsable;
  final DateTime fechaTraslado;

  // Geolocalización nueva
  final double? latitud;
  final double? longitud;
  final String? descripcion;

  // Geolocalización anterior
  final double? latitudAnterior;
  final double? longitudAnterior;
  final double? latitudNueva;
  final double? longitudNueva;

  Transfer({
    this.id,
    this.animalId,
    required this.nombreAnimal,
    this.ubicacionAnterior,
    this.motivo,
    this.observaciones,
    this.responsable,
    required this.fechaTraslado,
    this.latitud,
    this.longitud,
    this.descripcion,
    this.latitudAnterior,
    this.longitudAnterior,
    this.latitudNueva,
    this.longitudNueva,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'],
      animalId: json['animalId'],
      nombreAnimal: json['animal']?['nombre'] ?? json['nombreAnimal'],
      ubicacionAnterior: json['ubicacionAnterior'],
      motivo: json['motivo'],
      observaciones: json['observaciones'],
      responsable: json['responsable'],
      fechaTraslado: DateTime.parse(json['fechaTraslado']),
      latitud: (json['latitud'] as num?)?.toDouble(),
      longitud: (json['longitud'] as num?)?.toDouble(),
      descripcion: json['descripcion'],
      latitudAnterior: (json['latitudAnterior'] as num?)?.toDouble(),
      longitudAnterior: (json['longitudAnterior'] as num?)?.toDouble(),
      latitudNueva: (json['latitudNueva'] as num?)?.toDouble(),
      longitudNueva: (json['longitudNueva'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'ubicacionAnterior': ubicacionAnterior,
      'motivo': motivo,
      'observaciones': observaciones,
      'responsable': responsable,
      'fechaTraslado': fechaTraslado.toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      'descripcion': descripcion,
      'latitudAnterior': latitudAnterior,
      'longitudAnterior': longitudAnterior,
      'latitudNueva': latitudNueva,
      'longitudNueva': longitudNueva,
    };
  }
}
