import 'package:sistema_animales/models/adoption_model.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/evaluation_model.dart';
import 'package:sistema_animales/models/liberacion_model.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/models/transfer_model.dart';
import 'package:sistema_animales/models/tratamiento_model.dart';

class AnimalHistorial {
  final Animal animal;
  final Rescuer rescatista;
  final List<Evaluation> evaluations;
  final List<Tratamiento> treatments;
  final List<Transfer> transfers;
  final List<Liberacion> liberations;
  final List<Adoption> adoptions;

  AnimalHistorial({
    required this.animal,
    required this.rescatista,
    required this.evaluations,
    required this.treatments,
    required this.transfers,
    required this.liberations,
    required this.adoptions,
  });

  factory AnimalHistorial.fromJson(Map<String, dynamic> json) {
    return AnimalHistorial(
      animal: Animal.fromJson(json['animal']),
      rescatista: Rescuer.fromJson(json['rescatista']),
      evaluations: (json['evaluations'] as List?)
              ?.map((e) => Evaluation.fromJson(e))
              .toList() ??
          [],
      treatments: (json['treatments'] as List?)
              ?.map((t) => Tratamiento.fromJson(t))
              .toList() ??
          [],
      transfers: (json['transfers'] as List?)
              ?.map((t) => Transfer.fromJson(t))
              .toList() ??
          [],
      liberations: (json['liberations'] as List?)
              ?.map((l) => Liberacion.fromJson(l))
              .toList() ??
          [],
      adoptions: (json['adoptions'] as List?)
              ?.map((a) => Adoption.fromJson(a))
              .toList() ??
          [],
    );
  }
}
