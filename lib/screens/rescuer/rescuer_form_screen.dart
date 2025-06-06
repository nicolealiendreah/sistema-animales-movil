import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/servicess/rescuer_service.dart';
import 'package:sistema_animales/widgets/custom_form_text_field.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:sistema_animales/models/geolocalizacion_model.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class RescuerFormScreen extends StatefulWidget {
  const RescuerFormScreen({super.key});

  @override
  State<RescuerFormScreen> createState() => _RescuerFormScreenState();
}

class _RescuerFormScreenState extends State<RescuerFormScreen> {
  XFile? _pickedImage;
  DateTime? _fechaRescatista;
  latlng.LatLng? _selectedPosition;
  bool _isMapReady = false;

  final _formKey = GlobalKey<FormState>();
  final _rescuerService = RescuerService();
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final MapController _mapController = MapController();

  Future<void> _selectfechaRescatista(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaRescatista ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaRescatista = picked;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _guardarRescatista() async {
    if (!_formKey.currentState!.validate() || _fechaRescatista == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos obligatorios')),
      );
      return;
    }

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe seleccionar una imagen del rescatista')),
      );
      return;
    }

    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final extension = _pickedImage!.path.split('.').last.toLowerCase();

    if (!allowedExtensions.contains(extension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Solo se permiten imágenes JPG, PNG o GIF')),
      );
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Debe seleccionar una ubicación en el mapa')),
      );
      return;
    }

    final geo = Geolocalizacion(
      id: '',
      latitud: _selectedPosition!.latitude,
      longitud: _selectedPosition!.longitude,
      descripcion: _ubicacionController.text.isNotEmpty
          ? _ubicacionController.text
          : 'Ubicación seleccionada',
    );

    final nuevo = Rescuer(
      nombre: _nombreController.text,
      telefono: _telefonoController.text,
      fechaRescatista: _fechaRescatista!,
      geolocalizacion: geo,
    );

    try {
      await _rescuerService.create(nuevo, imageFile: _pickedImage);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _cargarUbicacionInicial();
  }

  Future<void> _cargarUbicacionInicial() async {
    try {
      final permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de ubicación denegado')),
        );
        return;
      }

      final posicion = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedPosition =
            latlng.LatLng(posicion.latitude, posicion.longitude);
        _isMapReady = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener ubicación: $e')),
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
                    const Text('Registrar Rescatista',
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
                        const Text('Datos del Rescatista',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          hintText: 'Nombre',
                          controller: _nombreController,
                          icon: Icons.person,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          hintText: 'Teléfono',
                          controller: _telefonoController,
                          icon: Icons.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Este campo es obligatorio';
                            }
                            if (!RegExp(r'^\d+$').hasMatch(value)) {
                              return 'Solo se permiten números';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectfechaRescatista(context),
                          child: AbsorbPointer(
                            child: CustomFormTextField(
                              hintText: 'Seleccionar fecha de Nacimiento',
                              controller: _fechaController,
                              icon: Icons.calendar_today,
                              validator: _requiredValidator,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Ubicación del rescatista:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 200,
                          child: FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: _selectedPosition ??
                                  latlng.LatLng(-17.7832, -63.1817),
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
                        const SizedBox(height: 16),
                        const SizedBox(height: 8),
                        const Text('Imagen del Rescatista',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () async {
                            try {
                              final picked = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (picked != null) {
                                final path = picked.path;
                                final ext = path.split('.').last.toLowerCase();
                                const allowed = ['jpg', 'jpeg', 'png', 'gif'];

                                if (!allowed.contains(ext)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Solo se permiten imágenes JPG, PNG o GIF')),
                                  );
                                  return;
                                }

                                setState(() {
                                  _pickedImage = picked;
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error al seleccionar imagen: $e')),
                              );
                            }
                          },
                          child: Container(
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey),
                            ),
                            child: _pickedImage != null
                                ? Image.file(File(_pickedImage!.path),
                                    fit: BoxFit.cover)
                                : const Center(
                                    child: Icon(Icons.add_a_photo, size: 40)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _guardarRescatista,
                          label: const Text('Guardar Detalles Rescatista'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 60),
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
