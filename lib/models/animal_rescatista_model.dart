import 'animal_model.dart';
import 'rescuer_model.dart';

class AnimalRescatista {
  final Animal animal;
  final Rescuer? rescuer;

  AnimalRescatista({required this.animal, this.rescuer});

  String? get id => animal.id;

  factory AnimalRescatista.fromJson(Map<String, dynamic> json) {
    final rescJson = json['rescatista'];
    final geoJson = json['geolocalizacion'];

    final rescuer = rescJson != null
        ? Rescuer.fromJson({
            ...rescJson,
            if (geoJson != null) 'geolocalizacion': geoJson,
          })
        : null;

    return AnimalRescatista(
      animal: Animal.fromJson(json),
      rescuer: rescuer,
    );
  }
}
