class Geolocalizacion {
  final String id;
  final double latitud;
  final double longitud;
  final String descripcion;
  final DateTime? fechaRegistro;

  Geolocalizacion({
    required this.id,
    required this.latitud,
    required this.longitud,
    required this.descripcion,
    this.fechaRegistro,
  });

  factory Geolocalizacion.fromJson(Map<String, dynamic> json) {
    return Geolocalizacion(
      id: json['id'] ?? json['_id'],
      latitud: json['latitud']?.toDouble() ?? 0.0,
      longitud: json['longitud']?.toDouble() ?? 0.0,
      descripcion: json['descripcion'] ?? '',
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitud': latitud,
      'longitud': longitud,
      'descripcion': descripcion,
    };
  }
}
