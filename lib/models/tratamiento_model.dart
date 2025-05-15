class Tratamiento {
  final String? id;
  final String? animalId;
  final String nombreAnimal;
  final String? tratamiento;
  final DateTime? fechaTratamiento;
  final String? responsable;
  final String? observaciones;
  final String? duracion;

  Tratamiento({
    this.id,
    this.animalId,
    required this.nombreAnimal,
    this.tratamiento,
    this.fechaTratamiento,
    this.responsable,
    this.observaciones,
    this.duracion,
  });


    factory Tratamiento.fromJson(Map<String, dynamic> json) {
    return Tratamiento(
      id: json['id'],
      animalId: json['animalId'],
      nombreAnimal: json['animal']?['nombre'] ?? json['nombreAnimal'] ?? 'Desconocido',
      tratamiento: json['tratamiento'] ?? '',
      fechaTratamiento: json['fechaTratamiento'] != null
          ? DateTime.parse(json['fechaTratamiento'])
          : null,
      responsable: json['responsableNombre'] ?? '',
      observaciones: json['observaciones'] ?? '',
      duracion: json['duracion'] ?? '',
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
