class Animal {
  final String? id;
  final String nombre;
  final String? especie;
  final String? raza;
  final String? sexo;
  final int? edad;
  final String? estadoSalud;
  final String? tipoAlimentacion;
  final String? cantidadRecomendada;
  final String? frecuenciaRecomendada;
  final DateTime? fechaLiberacion;
  final String? ubicacionLiberacion;

  Animal({
    this.id,
    required this.nombre,
    this.especie,
    this.raza,
    this.sexo,
    this.edad,
    this.estadoSalud,
    this.tipoAlimentacion,
    this.cantidadRecomendada,
    this.frecuenciaRecomendada,
    this.fechaLiberacion,
    this.ubicacionLiberacion,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      id: json['id'].toString(), 
      nombre: json['nombre'],
      especie: json['especie'],
      raza: json['raza'],
      sexo: json['sexo'],
      edad: json['edad'],
      estadoSalud: json['estadoSalud'],
      tipoAlimentacion: json['tipoAlimentacion'],
      cantidadRecomendada: json['cantidadRecomendada'],
      frecuenciaRecomendada: json['frecuenciaRecomendada'],
      fechaLiberacion: json['fechaLiberacion'] != null
          ? DateTime.parse(json['fechaLiberacion'])
          : null,
      ubicacionLiberacion: json['ubicacionLiberacion'],
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
      'tipoAlimentacion': tipoAlimentacion,
      'cantidadRecomendada': cantidadRecomendada,
      'frecuenciaRecomendada': frecuenciaRecomendada,
      'fechaLiberacion': fechaLiberacion?.toIso8601String(),
      'ubicacionLiberacion': ubicacionLiberacion,
    };
  }
}
