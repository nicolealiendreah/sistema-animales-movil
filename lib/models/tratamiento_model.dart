class Tratamiento {
  final String? id;
  final String? animalId;
  final String nombreAnimal;
  final String tratamiento;
  final DateTime? fechaTratamiento;
  final String responsable;
  final String observaciones;
  final String duracion;

  Tratamiento({
    this.id,
    this.animalId,
    required this.nombreAnimal,
    required this.tratamiento,
    this.fechaTratamiento,
    required this.responsable,
    required this.observaciones,
    required this.duracion,
  });

  factory Tratamiento.fromJson(Map<String, dynamic> json) {
    return Tratamiento(
      id: json['id'],
      animalId: json['animalId'],
      nombreAnimal: json['animal']?['nombre'] ?? json['nombreAnimal'] ?? 'Sin nombre',
      tratamiento: json['tratamiento'] ?? 'Sin tratamiento',
      fechaTratamiento: json['fechaTratamiento'] != null
          ? DateTime.tryParse(json['fechaTratamiento'])
          : null,
      responsable: json['responsableNombre'] ?? 'Desconocido',
      observaciones: json['observaciones'] ?? 'Sin observaciones',
      duracion: json['duracion'] ?? 'Sin duración',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'tratamiento': tratamiento,
      'fechaTratamiento': fechaTratamiento?.toIso8601String(),
      'responsableNombre': responsable,
      'observaciones': observaciones,
      'duracion': duracion,
    };
  }
}
