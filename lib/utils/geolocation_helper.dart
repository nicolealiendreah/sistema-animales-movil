import 'package:geocoding/geocoding.dart';
import 'package:sistema_animales/models/geolocalizacion_model.dart';

Future<void> traducirCoordenadasAGoogleMaps(Geolocalizacion geo) async {
  final descripcionActual = geo.descripcion.trim().toLowerCase();

  if (descripcionActual.isEmpty || descripcionActual == 'ubicación seleccionada' || descripcionActual == 'null') {
    try {
      final placemarks = await placemarkFromCoordinates(geo.latitud, geo.longitud);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        geo.descripcion = '${p.street ?? ''}, ${p.locality ?? ''}';
      }
    } catch (e) {
      print('Error al traducir coordenadas: $e');
    }
  }
}
