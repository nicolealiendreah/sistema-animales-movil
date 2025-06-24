class Transfer {
  final String? id;
  final String? animalId;
  final String nombreAnimal;
  final String? ubicacionAnterior;
  final String? motivo;
  final String? observaciones;
  final String? responsable;
  final DateTime? fechaTraslado;
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
    this.fechaTraslado,
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
      nombreAnimal:
          json['animal']?['nombre'] ?? json['nombreAnimal'] ?? 'Sin nombre',
      ubicacionAnterior: anterior?['descripcion'],
      motivo: json['motivo'],
      observaciones: json['observaciones'],
      responsable: json['responsable'],
      fechaTraslado: json['fechaTraslado'] != null
          ? DateTime.tryParse(json['fechaTraslado'])
          : null,
      latitudAnterior: anterior?['latitud']?.toDouble(),
      longitudAnterior: anterior?['longitud']?.toDouble(),
      latitudNueva: nueva?['latitud']?.toDouble(),
      longitudNueva: nueva?['longitud']?.toDouble(),
      descripcion: nueva?['descripcion'],
      latitud: nueva?['latitud']?.toDouble(),
      longitud: nueva?['longitud']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'ubicacionAnterior': ubicacionAnterior ?? 'Ubicación seleccionada',
      'motivo': motivo,
      'observaciones': observaciones,
      'responsable': responsable,
      'fechaTraslado': fechaTraslado?.toIso8601String(),
      'latitud': latitud,
      'longitud': longitud,
      'descripcion': descripcion ?? 'Ubicación seleccionada',
      'latitudAnterior': latitudAnterior,
      'longitudAnterior': longitudAnterior,
      'latitudNueva': latitudNueva,
      'longitudNueva': longitudNueva,
    };
  }
}
