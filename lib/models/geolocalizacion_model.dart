class Geolocalizacion {
  final String id;
  final double latitud;
  final double longitud;
  final String? descripcion;
  final DateTime? fechaRegistro;

  Geolocalizacion({
    required this.id,
    required this.latitud,
    required this.longitud,
    this.descripcion,
    this.fechaRegistro,
  });

  factory Geolocalizacion.fromJson(Map<String, dynamic> json) {
    return Geolocalizacion(
      id: json['id'],
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      descripcion: json['descripcion'],
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.tryParse(json['fechaRegistro'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitud': latitud,
      'longitud': longitud,
      'descripcion': descripcion,
    };
  }
}
