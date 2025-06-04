import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/transfer_model.dart';
import 'package:sistema_animales/servicess/transfer_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class TransferFormScreen extends StatefulWidget {
  final Animal animal;

  const TransferFormScreen({super.key, required this.animal});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TransferService();

  final TextEditingController _ubicacionAnterior = TextEditingController();
  final TextEditingController _ubicacionNueva = TextEditingController();
  final TextEditingController _motivo = TextEditingController();
  final TextEditingController _responsable = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();

  DateTime? _fechaTraslado;
  LatLng? _posicionAnterior;
  LatLng? _posicionNueva;

  MapController _mapAnterior = MapController();
  MapController _mapNueva = MapController();

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _fechaTraslado =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  @override
  void initState() {
    super.initState();
    _cargarUbicacionInicial();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final transfer = Transfer(
      nombreAnimal: widget.animal.nombre,
      ubicacionAnterior: _ubicacionAnterior.text,
      motivo: _motivo.text,
      observaciones: _observaciones.text,
      responsable: _responsable.text,
      fechaTraslado: _fechaTraslado ?? DateTime.now(),
      latitudAnterior: _posicionAnterior?.latitude,
      longitudAnterior: _posicionAnterior?.longitude,
      latitudNueva: _posicionNueva?.latitude,
      longitudNueva: _posicionNueva?.longitude,
      descripcion: _ubicacionNueva.text.isNotEmpty
          ? _ubicacionNueva.text
          : 'Ubicación seleccionada',
    );

    print('Enviando Transfer: ${transfer.toJson()}');

    try {
      await _service.create(transfer);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Traslado registrado')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _cargarUbicacionInicial() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) return;

    final position = await Geolocator.getCurrentPosition();

    if (!mounted) return;

    setState(() {
      _posicionAnterior = LatLng(position.latitude, position.longitude);
    });
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

  String _formatTime(DateTime? date) =>
      date != null ? DateFormat.jm().format(date) : '-';

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
                    Expanded(
                      child: Text(
                        'Historial de Traslados y Seguimiento',
                        style: AppTextStyles.heading.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text('Ubicación Anterior (toque el mapa):',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: 200,
                          child: FlutterMap(
                            mapController: _mapAnterior,
                            options: MapOptions(
                              initialCenter: _posicionAnterior ??
                                  LatLng(-17.7832, -63.1817),
                              initialZoom: 15,
                              onTap: (_, point) {
                                setState(() {
                                  _posicionAnterior = point;
                                });
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              if (_posicionAnterior != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 40,
                                      height: 40,
                                      point: _posicionAnterior!,
                                      child: const Icon(Icons.location_pin,
                                          size: 40, color: Colors.blue),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        Text(
                          _posicionAnterior != null
                              ? 'Lat: ${_posicionAnterior!.latitude.toStringAsFixed(5)} - Lng: ${_posicionAnterior!.longitude.toStringAsFixed(5)}'
                              : 'Toque el mapa para seleccionar una ubicación anterior.',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Ubicación Nueva (toque en el mapa):',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: FlutterMap(
                            mapController: _mapNueva,
                            options: MapOptions(
                              initialCenter:
                                  _posicionNueva ?? LatLng(-17.7832, -63.1817),
                              initialZoom: 15,
                              onTap: (tapPos, point) {
                                setState(() => _posicionNueva = point);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                subdomains: ['a', 'b', 'c'],
                              ),
                              if (_posicionNueva != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      width: 40,
                                      height: 40,
                                      point: _posicionNueva!,
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
                          _posicionNueva != null
                              ? 'Lat: ${_posicionNueva!.latitude.toStringAsFixed(5)} - Lng: ${_posicionNueva!.longitude.toStringAsFixed(5)}'
                              : 'Toque el mapa para seleccionar una ubicación.',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        _buildField('Motivo Traslado', _motivo),
                        _buildField('Responsable del Traslado', _responsable),
                        _buildField('Observaciones', _observaciones),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Fecha de Traslado:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _pickDateTime,
                              child: Text(_formatDate(_fechaTraslado),
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                            TextButton(
                              onPressed: _pickDateTime,
                              child: Text(_formatTime(_fechaTraslado),
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('GUARDAR'),
                        ),
                        const SizedBox(height: 32),
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

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
