class Adoption {
  final String? id;
  final String nombreAnimal;
  final String? estado;
  final String? nombreAdoptante;
  final String? contactoAdoptante;
  final String? direccionAdoptante;
  final String? observaciones;
  final DateTime fechaAdopcion;

  Adoption({
    this.id,
    required this.nombreAnimal,
    this.estado,
    this.nombreAdoptante,
    this.contactoAdoptante,
    this.direccionAdoptante,
    this.observaciones,
    required this.fechaAdopcion,
  });

  factory Adoption.fromJson(Map<String, dynamic> json) {
    return Adoption(
      id: json['id'] ?? json['_id'],
      nombreAnimal: json['nombreAnimal'] ?? '',
      estado: json['estado'],
      nombreAdoptante: json['nombreAdoptante'],
      contactoAdoptante: json['contactoAdoptante'],
      direccionAdoptante: json['direccionAdoptante'],
      observaciones: json['observaciones'],
      fechaAdopcion: DateTime.parse(json['fechaAdopcion']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'estado': estado,
      'nombreAdoptante': nombreAdoptante,
      'contactoAdoptante': contactoAdoptante,
      'direccionAdoptante': direccionAdoptante,
      'observaciones': observaciones,
      'fechaAdopcion': fechaAdopcion.toIso8601String(),
    };
  }
}
