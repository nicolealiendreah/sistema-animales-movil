import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';
import 'package:sistema_animales/models/geolocalizacion_model.dart';
import 'package:sistema_animales/servicess/geolocalizacion_service.dart';
import 'package:geocoding/geocoding.dart';

class GeolocationScreen extends StatefulWidget {
  const GeolocationScreen({super.key});

  @override
  State<GeolocationScreen> createState() => _GeolocationScreenState();
}

class _GeolocationScreenState extends State<GeolocationScreen> {
  final GeolocalizacionService _geoService = GeolocalizacionService();
  List<Geolocalizacion> _ubicaciones = [];
  List<String> _direcciones = [];

  @override
  void initState() {
    super.initState();
    _cargarGeolocalizaciones();
  }

  Future<void> _cargarGeolocalizaciones() async {
    try {
      final data = await _geoService.getAll();

      // Generar dirección estimada por cada ubicación
      final dirList = await Future.wait(data.map((e) async {
        try {
          final placemarks = await placemarkFromCoordinates(e.latitud, e.longitud);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            return '${p.street ?? ''}, ${p.locality ?? ''}';
          }
        } catch (_) {}
        return 'Ubicación desconocida';
      }));

      setState(() {
        _ubicaciones = data;
        _direcciones = dirList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al cargar geolocalizaciones')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background2.jpg', fit: BoxFit.cover),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 16),
                color: AppColors.primary,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Geolocalización y Monitoreo',
                        style: AppTextStyles.heading,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial de ubicaciones',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      if (_ubicaciones.isEmpty)
                        const Center(child: Text('No hay registros de geolocalización.'))
                      else
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Table(
                            border: TableBorder.all(color: Colors.black26),
                            columnWidths: const {
                              0: FlexColumnWidth(1.5),
                              1: FlexColumnWidth(2),
                              2: FlexColumnWidth(3),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(color: AppColors.primary),
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Fecha',
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Descripción',
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('Ubicación Estimada',
                                        style: TextStyle(
                                            color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              ...List.generate(_ubicaciones.length, (i) {
                                final ubicacion = _ubicaciones[i];
                                final direccion = _direcciones.length > i ? _direcciones[i] : '-';
                                return TableRow(children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(ubicacion.fechaRegistro
                                            ?.toLocal()
                                            .toString()
                                            .split(' ')[0] ??
                                        ''),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(ubicacion.descripcion ?? ''),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(direccion),
                                  ),
                                ]);
                              }),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.geolocationForm)
                                .then((value) {
                              if (value == true) _cargarGeolocalizaciones();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('NUEVA UBICACIÓN'),
                        ),
                      ),
                    ],
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
