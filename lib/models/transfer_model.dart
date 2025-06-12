class Transfer {
  final String? id;
  final String? animalId;
  final String nombreAnimal;
  final String? ubicacionAnterior;
  final String? motivo;
  final String? observaciones;
  final String? responsable;
  final DateTime fechaTraslado;
  final double? latitud;
  final double? longitud;
  final String? descripcion;
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
    final anterior = json['ubicacionAnterior'];
    final nueva = json['ubicacionNueva'];

    return Transfer(
      id: json['id'],
      animalId: json['animalId'],
      nombreAnimal: json['animal']?['nombre'] ?? json['nombreAnimal'],
      ubicacionAnterior: anterior?['descripcion'],
      motivo: json['motivo'],
      observaciones: json['observaciones'],
      responsable: json['responsable'],
      fechaTraslado: DateTime.parse(json['fechaTraslado']),
      latitudAnterior: anterior?['latitud']?.toDouble(),
      longitudAnterior: anterior?['longitud']?.toDouble(),
      latitudNueva: nueva?['latitud']?.toDouble(),
      longitudNueva: nueva?['longitud']?.toDouble(),
      descripcion: nueva?['descripcion'], // opcional, si lo necesitas
      latitud:
          nueva?['latitud']?.toDouble(), // redundante si ya usas latitudNueva
      longitud: nueva?['longitud']?.toDouble(), // igual aquí
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
