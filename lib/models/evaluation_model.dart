class Evaluation {
  final String? id;
  final String nombreAnimal;
  final String diagnostico;
  final String? sintomasObservados;
  final String? tratamientoAdministrado;
  final String? medicacionRecetada;
  final String? veterinario;
  final DateTime? fechaEvaluacion;
  final DateTime? proximaRevision;

  Evaluation({
    this.id,
    required this.nombreAnimal,
    required this.diagnostico,
    this.sintomasObservados,
    this.tratamientoAdministrado,
    this.medicacionRecetada,
    this.veterinario,
    this.fechaEvaluacion,
    this.proximaRevision,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'] ?? json['_id'],
      nombreAnimal: json['nombreAnimal'] ?? '',
      diagnostico: json['diagnostico'],
      sintomasObservados: json['sintomasObservados'],
      tratamientoAdministrado: json['tratamientoAdministrado'],
      medicacionRecetada: json['medicacionRecetada'],
      veterinario: json['veterinario'],
      fechaEvaluacion: json['fechaEvaluacion'] != null
          ? DateTime.parse(json['fechaEvaluacion'])
          : null,
      proximaRevision: json['proximaRevision'] != null
          ? DateTime.parse(json['proximaRevision'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombreAnimal': nombreAnimal,
      'diagnostico': diagnostico,
      'sintomasObservados': sintomasObservados,
      'tratamientoAdministrado': tratamientoAdministrado,
      'medicacionRecetada': medicacionRecetada,
      'veterinario': veterinario,
      'fechaEvaluacion': fechaEvaluacion?.toIso8601String(),
      'proximaRevision': proximaRevision?.toIso8601String(),
    };
  }
}
