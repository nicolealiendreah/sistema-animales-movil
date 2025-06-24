import 'geolocalizacion_model.dart';

class Rescuer {
  final String? id;
  final String nombre;
  final String telefono;
  final DateTime fechaRescatista;
  final Geolocalizacion? geolocalizacion;
  final String? imagen;

  Rescuer({
    this.id,
    required this.nombre,
    required this.telefono,
    required this.fechaRescatista,
    this.geolocalizacion,
    this.imagen,
  });

  factory Rescuer.fromJson(Map<String, dynamic> json) {
    final geoJson = json['ubicacion'] ?? json['geolocalizacion'];

    return Rescuer(
      id: json['id']?.toString() ?? json['_id'],
      nombre: json['nombre'],
      telefono: json['telefono'],
      fechaRescatista: DateTime.parse(json['fechaRescatista']),
      geolocalizacion:
          geoJson != null ? Geolocalizacion.fromJson(geoJson) : null,
      imagen: json['imagen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'telefono': telefono,
      'fechaRescatista': fechaRescatista.toIso8601String(),
      'latitud': geolocalizacion?.latitud,
      'longitud': geolocalizacion?.longitud,
      'descripcion': geolocalizacion?.descripcion,
    };
  }
}
