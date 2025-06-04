import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_rescatista_model.dart';
import 'package:sistema_animales/models/liberacion_model.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/servicess/liberacion_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class LiberationFormScreen extends StatefulWidget {
  const LiberationFormScreen({super.key});

  @override
  State<LiberationFormScreen> createState() => _LiberationFormScreenState();
}

class _LiberationFormScreenState extends State<LiberationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _animalService = AnimalService();
  final _liberacionService = LiberacionService();

  List<AnimalRescatista> _animals = [];
  AnimalRescatista? _selectedAnimal;
  Liberacion? _liberacion;

  final TextEditingController ubicacionLiberacion = TextEditingController();
  final TextEditingController observaciones = TextEditingController();
  DateTime? _fechaLiberacion;
  LatLng? _selectedPosition;
  final MapController _mapController = MapController();

  @override
  @override
  void initState() {
    super.initState();
    _loadAnimals();
    _cargarUbicacionInicial();
  }

  Future<void> _cargarUbicacionInicial() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadAnimals() async {
    final list = await _animalService.getAll();
    setState(() {
      _animals = list;
    });
  }

  Future<void> _pickFechaLiberacion() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaLiberacion = picked;
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedAnimal != null) {
      final data = Liberacion(
        id: _liberacion?.id ?? '',
        animalId: _selectedAnimal!.animal.id!,
        nombreAnimal: _selectedAnimal!.animal.nombre,
        ubicacionLiberacion:
            ubicacionLiberacion.text,
        fechaLiberacion: _fechaLiberacion?.toIso8601String() ?? '',
        observaciones: observaciones.text,
        latitud: _selectedPosition?.latitude,
        longitud: _selectedPosition?.longitude,
        descripcion: ubicacionLiberacion.text.isNotEmpty
            ? ubicacionLiberacion.text
            : 'Ubicación seleccionada',
      );

      try {
        await _liberacionService.create(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Liberación guardada')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
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
                    const Text('Registrar Liberación',
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
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Nombre del animal:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DropdownButtonFormField<AnimalRescatista>(
                          value: _selectedAnimal,
                          items: _animals.map((animal) {
                            return DropdownMenuItem(
                              value: animal,
                              child: Text(animal.animal.nombre),
                            );
                          }).toList(),
                          onChanged: (animal) {
                            if (animal != null) {
                              setState(() {
                                _selectedAnimal = animal;
                                _liberacion = null;
                                ubicacionLiberacion.clear();
                                observaciones.clear();
                                _fechaLiberacion = null;
                              });
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Nombre Animal',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Ubicación de liberación en el mapa:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _selectedPosition ??
                                  LatLng(-17.7832, -63.1817),
                              initialZoom: 15,
                              onTap: (tapPosition, point) {
                                setState(() {
                                  _selectedPosition = point;
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
                        _buildField('Observaciones', observaciones,
                            maxLines: 3),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Fecha de liberación:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _pickFechaLiberacion,
                              child: Text(_formatDate(_fechaLiberacion),
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('GUARDAR'),
                        ),
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

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
