class Geolocalizacion {
  final String id;
  final double latitud;
  final double longitud;
  String descripcion;
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
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      latitud: (json['latitud'] ?? 0.0).toDouble(),
      longitud: (json['longitud'] ?? 0.0).toDouble(),
      descripcion: (json['descripcion'] ?? '').toString(),
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
