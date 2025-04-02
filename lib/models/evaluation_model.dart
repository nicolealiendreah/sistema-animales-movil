class Evaluation {
  final String? id;
  final String animalId;
  final String diagnostico;
  final String? sintomas;
  final String? tratamiento;
  final String? medicacion;
  final String? veterinario;
  final DateTime fechaEvaluacion;
  final DateTime? proximaRevision;

  Evaluation({
    this.id,
    required this.animalId,
    required this.diagnostico,
    this.sintomas,
    this.tratamiento,
    this.medicacion,
    this.veterinario,
    required this.fechaEvaluacion,
    this.proximaRevision,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['_id'],
      animalId: json['animalId'],
      diagnostico: json['diagnostico'],
      sintomas: json['sintomas'],
      tratamiento: json['tratamiento'],
      medicacion: json['medicacion'],
      veterinario: json['veterinario'],
      fechaEvaluacion: DateTime.parse(json['fechaEvaluacion']),
      proximaRevision: json['proximaRevision'] != null
          ? DateTime.parse(json['proximaRevision'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'animalId': animalId,
      'diagnostico': diagnostico,
      'sintomas': sintomas,
      'tratamiento': tratamiento,
      'medicacion': medicacion,
      'veterinario': veterinario,
      'fechaEvaluacion': fechaEvaluacion.toIso8601String(),
      'proximaRevision': proximaRevision?.toIso8601String(),
    };
  }
}
