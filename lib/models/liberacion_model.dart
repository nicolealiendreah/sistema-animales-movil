class Liberacion {
  final String id;
  final String nombreAnimal;
  final String ubicacionLiberacion;
  final String fechaLiberacion;
  final String observaciones;

  Liberacion({
    required this.id,
    required this.nombreAnimal,
    required this.ubicacionLiberacion,
    required this.fechaLiberacion,
    required this.observaciones,
  });

  factory Liberacion.fromJson(Map<String, dynamic> json) {
    return Liberacion(
      id: json['id'],
      nombreAnimal: json['nombreAnimal'],
      ubicacionLiberacion: json['ubicacionLiberacion'],
      fechaLiberacion: json['fechaLiberacion'],
      observaciones: json['observaciones'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombreAnimal': nombreAnimal,
        'ubicacionLiberacion': ubicacionLiberacion,
        'fechaLiberacion': fechaLiberacion,
        'observaciones': observaciones,
      };
}
