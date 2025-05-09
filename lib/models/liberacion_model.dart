class Liberacion {
  final String id;
  final String animalId;
  final String? nombreAnimal;
  final String ubicacionLiberacion;
  final String fechaLiberacion;
  final String observaciones;

  Liberacion({
    required this.id,
    required this.animalId,
    this.nombreAnimal,
    required this.ubicacionLiberacion,
    required this.fechaLiberacion,
    required this.observaciones,
  });

  factory Liberacion.fromJson(Map<String, dynamic> json) {
    return Liberacion(
      id: json['id'],
      animalId: json['animalId'],
      nombreAnimal: json['animal']?['nombre'] ?? json['nombreAnimal'],
      ubicacionLiberacion: json['ubicacionLiberacion'],
      fechaLiberacion: json['fechaLiberacion'],
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'ubicacionLiberacion': ubicacionLiberacion,
      'fechaLiberacion': fechaLiberacion,
      'observaciones': observaciones,
    };
  }
}
