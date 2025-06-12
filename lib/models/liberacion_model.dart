class Liberacion {
  final String id;
  final String animalId;
  final String? nombreAnimal;
  final String ubicacionLiberacion;
  final String fechaLiberacion;
  final String observaciones;
  final double? latitud;
  final double? longitud;
  final String? descripcion;

  Liberacion({
    required this.id,
    required this.animalId,
    this.nombreAnimal,
    required this.ubicacionLiberacion,
    required this.fechaLiberacion,
    required this.observaciones,
    this.latitud,
    this.longitud,
    this.descripcion,
  });

  factory Liberacion.fromJson(Map<String, dynamic> json) {
    final ubicacion = json['ubicacionLiberacion'];
    return Liberacion(
      id: json['id'],
      animalId: json['animalId'],
      nombreAnimal: json['animal']?['nombre'],
      fechaLiberacion: json['fechaLiberacion'],
      observaciones: json['observaciones'],
      latitud: ubicacion?['latitud']?.toDouble(),
      longitud: ubicacion?['longitud']?.toDouble(),
      descripcion: ubicacion?['descripcion'],
      ubicacionLiberacion: ubicacion != null ? ubicacion.toString() : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'ubicacionLiberacion': ubicacionLiberacion,
      'fechaLiberacion': fechaLiberacion,
      'observaciones': observaciones,
      'latitud': latitud,
      'longitud': longitud,
      'descripcion': descripcion,
    };
  }
}
