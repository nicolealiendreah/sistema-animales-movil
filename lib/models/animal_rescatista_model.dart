import 'animal_model.dart';
import 'rescuer_model.dart';

class AnimalRescatista {
  final Animal animal;
  final Rescuer rescuer;

  AnimalRescatista({required this.animal, required this.rescuer});

  String? get id => animal.id;

  factory AnimalRescatista.fromJson(Map<String, dynamic> json) {
    return AnimalRescatista(
      animal: Animal.fromJson(json),
      rescuer: Rescuer.fromJson(json['rescatista']),
    );
  }
}
