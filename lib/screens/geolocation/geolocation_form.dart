import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/geolocalizacion_model.dart';
import 'package:sistema_animales/servicess/geolocalizacion_service.dart';

class GeolocationFormScreen extends StatefulWidget {
  const GeolocationFormScreen({super.key});

  @override
  State<GeolocationFormScreen> createState() => _GeolocationFormScreenState();
}

class _GeolocationFormScreenState extends State<GeolocationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _latitud = TextEditingController();
  final _longitud = TextEditingController();
  final _descripcion = TextEditingController();

  final GeolocalizacionService _geoService = GeolocalizacionService();
  LatLng? _selectedPosition;
  MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _cargarUbicacionActual();
  }

  Future<void> _cargarUbicacionActual() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedPosition = LatLng(pos.latitude, pos.longitude);
      _latitud.text = pos.latitude.toString();
      _longitud.text = pos.longitude.toString();
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final lat = double.parse(_latitud.text);
      final lng = double.parse(_longitud.text);

      final placemarks = await placemarkFromCoordinates(lat, lng);
      final direccion = placemarks.isNotEmpty
          ? '${placemarks.first.street}, ${placemarks.first.locality}'
          : 'Ubicación desconocida';

      final geo = Geolocalizacion(
        id: '',
        latitud: lat,
        longitud: lng,
        descripcion:
            _descripcion.text.isNotEmpty ? _descripcion.text : direccion,
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
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background2.jpg', fit: BoxFit.cover),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 16),
                color: AppColors.primary,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text('Registrar Geolocalización',
                        style: AppTextStyles.heading),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Seleccione una ubicación en el mapa:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 250,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _selectedPosition ??
                                  LatLng(-17.7832, -63.1817),
                              initialZoom: 15,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _selectedPosition = point;
                                  _latitud.text = point.latitude.toString();
                                  _longitud.text = point.longitude.toString();
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              if (_selectedPosition != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 40,
                                      height: 40,
                                      point: _selectedPosition!,
                                      child: const Icon(Icons.location_pin,
                                          size: 40, color: Colors.red),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedPosition != null
                              ? 'Lat: ${_selectedPosition!.latitude.toStringAsFixed(5)} - Lng: ${_selectedPosition!.longitude.toStringAsFixed(5)}'
                              : 'Toque el mapa para seleccionar una ubicación.',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _latitud,
                          decoration: const InputDecoration(
                            labelText: 'Latitud',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Campo obligatorio'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _longitud,
                          decoration: const InputDecoration(
                            labelText: 'Longitud',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) => value == null || value.isEmpty
                              ? 'Campo obligatorio'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _descripcion,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: _guardar,
                          label: const Text('Guardar Ubicación'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
