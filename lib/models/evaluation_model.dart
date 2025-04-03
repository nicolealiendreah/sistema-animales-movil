class Evaluation {
  final int? id;
  final int animalId;
  final String diagnostico;
  final String? sintomasObservados;
  final String? tratamientoAdministrado;
  final String? medicacionRecetada;
  final String? veterinario;
  final DateTime? fechaEvaluacion;
  final DateTime? proximaRevision;

  Evaluation({
    this.id,
    required this.animalId,
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
      id: json['id'],
      animalId: json['animalId'],
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
      'animalId': animalId,
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
