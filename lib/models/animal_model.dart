class Animal {
  final String? id;
  final String nombre;
  final String? especie;
  final String? raza;
  final String? sexo;
  final int? edad;
  final String? estadoSalud;
  final String? tipo;
  final String? tipoAlimentacion;
  final String? cantidadRecomendada;
  final String? frecuenciaRecomendada;
  final DateTime? fechaRescate;
  final String? ubicacionRescate;
  final String? detallesRescate;
  final String? nombreRescatista;
  final String? telefonoRescatista;

  Animal({
    this.id,
    required this.nombre,
    this.especie,
    this.raza,
    this.sexo,
    this.edad,
    this.estadoSalud,
    this.tipo,
    this.tipoAlimentacion,
    this.cantidadRecomendada,
    this.frecuenciaRecomendada,
    this.fechaRescate,
    this.ubicacionRescate,
    this.detallesRescate,
    this.nombreRescatista,
    this.telefonoRescatista,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id']?.toString(),
      nombre: json['nombre'],
      especie: json['especie'],
      raza: json['raza'],
      sexo: json['sexo'],
      edad: json['edad'],
      estadoSalud: json['estadoSalud'],
      tipo: json['tipo'],
      tipoAlimentacion: json['tipoAlimentacion'],
      cantidadRecomendada: json['cantidadRecomendada'],
      frecuenciaRecomendada: json['frecuenciaRecomendada'],
      fechaRescate: json['fechaRescate'] != null
          ? DateTime.parse(json['fechaRescate'])
          : null,
      ubicacionRescate: json['ubicacionRescate'],
      detallesRescate: json['detallesRescate'],
      nombreRescatista: json['nombreRescatista'],
      telefonoRescatista: json['telefonoRescatista'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'especie': especie,
      'raza': raza,
      'sexo': sexo,
      'edad': edad,
      'estadoSalud': estadoSalud,
      'tipo': tipo,
      'tipoAlimentacion': tipoAlimentacion,
      'cantidadRecomendada': cantidadRecomendada,
      'frecuenciaRecomendada': frecuenciaRecomendada,
      'fechaRescate': fechaRescate?.toIso8601String(),
      'ubicacionRescate': ubicacionRescate,
      'detallesRescate': detallesRescate,
      'nombreRescatista': nombreRescatista,
      'telefonoRescatista': telefonoRescatista,
    };
  }
}
