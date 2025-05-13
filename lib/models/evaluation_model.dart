class Evaluation {
  final String? id;
  final String? animalId;
  final String nombreAnimal;
  final String diagnostico;
  final String? sintomas;
  final String? medicacion;
  final String? responsable;
  final DateTime? fechaEvaluacion;
  final DateTime? proximaRevision;

  Evaluation({
    this.id,
    this.animalId,
    required this.nombreAnimal,
    required this.diagnostico,
    this.sintomas,
    this.medicacion,
    this.responsable,
    this.fechaEvaluacion,
    this.proximaRevision,
  });

  factory Evaluation.fromJson(Map<String, dynamic> json) {
    return Evaluation(
      id: json['id'],
      animalId: json['animalId'],
      nombreAnimal: json['animal']?['nombre'] ?? json['nombreAnimal'],
      diagnostico: json['diagnostico'],
      sintomas: json['sintomas'],
      medicacion: json['medicacion'],
      responsable: json['responsable'],
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
      'sintomas': sintomas,
      'medicacion': medicacion,
      'responsable': responsable,
      'fechaEvaluacion': fechaEvaluacion?.toIso8601String(),
      'proximaRevision': proximaRevision?.toIso8601String(),
    };
  }
}
