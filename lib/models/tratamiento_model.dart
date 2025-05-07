class Tratamiento {
  final String id;
  final String nombreAnimal;
  final String tratamiento;
  final String fechaTratamiento;
  final String responsable;
  final String observaciones;
  final String duracion;

  Tratamiento({
    required this.id,
    required this.nombreAnimal,
    required this.tratamiento,
    required this.fechaTratamiento,
    required this.responsable,
    required this.observaciones,
    required this.duracion,
  });

  factory Tratamiento.fromJson(Map<String, dynamic> json) {
    return Tratamiento(
      id: json['id'],
      nombreAnimal: json['nombreAnimal'],
      tratamiento: json['tratamiento'],
      fechaTratamiento: json['fechaTratamiento'],
      responsable: json['responsable'],
      observaciones: json['observaciones'],
      duracion: json['duracion'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombreAnimal': nombreAnimal,
        'tratamiento': tratamiento,
        'fechaTratamiento': fechaTratamiento,
        'responsable': responsable,
        'observaciones': observaciones,
        'duracion': duracion,
      };
}
