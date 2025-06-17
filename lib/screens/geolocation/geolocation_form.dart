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
          SnackBar(
            content: const Text('Error al registrar ubicación'),
            backgroundColor: Colors.red.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      print('ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error inesperado'),
          backgroundColor: Colors.red.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background2.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16, 
                    left: 20, 
                    right: 20, 
                    bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Registrar Geolocalización',
                        style: AppTextStyles.heading,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Seleccione una ubicación',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                height: 280,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
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
                                              width: 50,
                                              height: 50,
                                              point: _selectedPosition!,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red,
                                                  borderRadius: BorderRadius.circular(25),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.red.withOpacity(0.3),
                                                      blurRadius: 10,
                                                      spreadRadius: 2,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.location_pin,
                                                  size: 30,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Text(
                                  _selectedPosition != null
                                      ? 'Lat: ${_selectedPosition!.latitude.toStringAsFixed(5)} - Lng: ${_selectedPosition!.longitude.toStringAsFixed(5)}'
                                      : 'Toque el mapa para seleccionar una ubicación',
                                  style: TextStyle(
                                    color: _selectedPosition != null ? Colors.black87 : Colors.grey[600],
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.edit_location,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Coordenadas y descripción',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _latitud,
                                      decoration: InputDecoration(
                                        labelText: 'Latitud',
                                        labelStyle: TextStyle(color: Colors.grey[600]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: const EdgeInsets.all(16),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value == null || value.isEmpty
                                          ? 'Campo obligatorio'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _longitud,
                                      decoration: InputDecoration(
                                        labelText: 'Longitud',
                                        labelStyle: TextStyle(color: Colors.grey[600]),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: const EdgeInsets.all(16),
                                      ),
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value == null || value.isEmpty
                                          ? 'Campo obligatorio'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _descripcion,
                                decoration: InputDecoration(
                                  labelText: 'Descripción',
                                  labelStyle: TextStyle(color: Colors.grey[600]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.all(16),
                                ),
                                maxLines: 3,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _guardar,
                            icon: const Icon(Icons.save_outlined, size: 22),
                            label: const Text(
                              'Guardar Ubicación',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
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