import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/geolocalizacion_model.dart';
import 'package:sistema_animales/servicess/geolocalizacion_service.dart';
import 'package:geocoding/geocoding.dart';

class GeolocationFormScreen extends StatefulWidget {
  const GeolocationFormScreen({super.key});

  @override
  State<GeolocationFormScreen> createState() => _GeolocationFormScreenState();
}

class _GeolocationFormScreenState extends State<GeolocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _latitud = TextEditingController();
  final TextEditingController _longitud = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();

  final GeolocalizacionService _geoService = GeolocalizacionService();

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final lat = double.parse(_latitud.text);
      final lng = double.parse(_longitud.text);

      final placemarks = await placemarkFromCoordinates(lat, lng);
      final direccion = placemarks.isNotEmpty
          ? '${placemarks.first.street}, ${placemarks.first.locality}'
          : 'Ubicación desconocida';

      print('📍 Dirección estimada: $direccion');

      final geo = Geolocalizacion(
        id: '',
        latitud: lat,
        longitud: lng,
        descripcion: _descripcion.text,
        fechaRegistro: null,
      );

      final success = await _geoService.create(geo);
      if (success && mounted) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar ubicación')),
        );
      }
    } catch (e) {
      print('ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inesperado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Registrar Geolocalización'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _latitud,
                decoration: const InputDecoration(labelText: 'Latitud'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _longitud,
                decoration: const InputDecoration(labelText: 'Longitud'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descripcion,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('GUARDAR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
