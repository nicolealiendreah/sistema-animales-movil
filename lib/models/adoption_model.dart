class Adoption {
  final String? id;
  final String animalId;
  final String? estado;
  final String? nombreAdoptante;
  final String? contactoAdoptante;
  final String? direccionAdoptante;
  final String? observaciones;
  final DateTime fechaAdopcion;

  Adoption({
    this.id,
    required this.animalId,
    this.estado,
    this.nombreAdoptante,
    this.contactoAdoptante,
    this.direccionAdoptante,
    this.observaciones,
    required this.fechaAdopcion,
  });

  factory Adoption.fromJson(Map<String, dynamic> json) {
    return Adoption(
      id: json['_id'],
      animalId: json['animalId'],
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
      'animalId': animalId,
      'estado': estado,
      'nombreAdoptante': nombreAdoptante,
      'contactoAdoptante': contactoAdoptante,
      'direccionAdoptante': direccionAdoptante,
      'observaciones': observaciones,
      'fechaAdopcion': fechaAdopcion.toIso8601String(),
    };
  }
}
