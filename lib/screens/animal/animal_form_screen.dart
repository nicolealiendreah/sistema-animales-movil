import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/servicess/rescuer_service.dart';
import 'package:sistema_animales/widgets/custom_form_text_field.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class AnimalFormScreen extends StatefulWidget {
  const AnimalFormScreen({super.key});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AnimalService();
  final _rescuerService = RescuerService();
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nombre = TextEditingController();
  final TextEditingController especie = TextEditingController();
  final TextEditingController raza = TextEditingController();
  final TextEditingController edad = TextEditingController();
  final TextEditingController estadoSalud = TextEditingController();
  final TextEditingController tipoAlimentacion = TextEditingController();
  final TextEditingController cantidadRecomendada = TextEditingController();
  final TextEditingController frecuenciaRecomendada = TextEditingController();
  final TextEditingController fechaRescateController = TextEditingController();
  final TextEditingController detalleRescate = TextEditingController();

  DateTime? _fechaRescate;
  String? selectedTipo;
  String? selectedSexo;
  String? selectedRescatista;
  String? selectedTelefono;
  List<Rescuer> rescatistas = [];
  DateTime? selectedFechaRescate;
  String? selectedUbicacionRescate;
  String? selectedDetalleRescate;
  String? selectedEstadoSalud;
  String? selectedFrecuenciaRecomendada;
  LatLng? _selectedPosition;
  MapController _mapController = MapController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaRescate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaRescate = picked;
        fechaRescateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _loadRescatistas() async {
    final lista = await _rescuerService.getAll();
    setState(() {
      rescatistas = lista;
    });
  }

  @override
  @override
  void initState() {
    super.initState();
    _loadRescatistas();
    _cargarUbicacionInicial();
  }

  Future<void> _cargarUbicacionInicial() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _selectedPosition = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, complete todos los campos obligatorios')),
      );
      return;
    }
    if (selectedRescatista == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un rescatista')),
      );
      return;
    }

    final selectedRescuer = rescatistas.firstWhere(
      (r) => r.nombre == selectedRescatista,
      orElse: () => throw Exception('Rescatista no encontrado'),
    );

    if (selectedRescuer.nombre.isEmpty || selectedRescuer.telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faltan datos del rescatista')),
      );
      return;
    }

    final data = {
      "nombre": nombre.text,
      "especie": especie.text,
      "raza": raza.text,
      "sexo": selectedSexo,
      "edad": int.tryParse(edad.text),
      "estadoSalud": selectedEstadoSalud,
      "tipo": selectedTipo,
      "tipoAlimentacion": tipoAlimentacion.text,
      "cantidadRecomendada": cantidadRecomendada.text,
      "frecuenciaRecomendada": selectedFrecuenciaRecomendada,
      "fechaRescate": _fechaRescate?.toIso8601String(),
      "detallesRescate": detalleRescate.text,
      "nombreRescatista": selectedRescuer.nombre,
      "telefonoRescatista": selectedRescuer.telefono,
      "fechaRescatista": selectedFechaRescate?.toIso8601String(),
      "latitud": _selectedPosition?.latitude,
      "longitud": _selectedPosition?.longitude,
      "descripcion": selectedUbicacionRescate ?? "Ubicación seleccionada"
    };
    print(
        "✅ Enviado: ${data['nombreRescatista']} - ${data['telefonoRescatista']}");

    final success = await _service.create(data, imageFile: _pickedImage);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal registrado exitosamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar animal')),
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
                    const Text('Datos del Animal',
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
                        const Text('Datos',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Nombre',
                            controller: nombre,
                            icon: Icons.pets,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Especie',
                            controller: especie,
                            icon: Icons.pets,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Raza',
                            controller: raza,
                            icon: Icons.pets,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedSexo,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.transgender),
                              labelText: 'Sexo'),
                          items: ['Macho', 'Hembra']
                              .map((sexo) => DropdownMenuItem(
                                  value: sexo, child: Text(sexo)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedSexo = value),
                          validator: (value) =>
                              value == null ? 'Seleccione un sexo' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Edad',
                            controller: edad,
                            icon: Icons.cake,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedEstadoSalud,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.health_and_safety),
                            labelText: 'Estado de Salud',
                          ),
                          items: ['Excelente', 'Bueno', 'Regular', 'Crítico']
                              .map((estado) => DropdownMenuItem(
                                  value: estado, child: Text(estado)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedEstadoSalud = value),
                          validator: (value) => value == null
                              ? 'Seleccione un estado de salud'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedTipo,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.category),
                              labelText: 'Tipo del Animal'),
                          items: ['Silvestre', 'Doméstico']
                              .map((tipo) => DropdownMenuItem(
                                  value: tipo, child: Text(tipo)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedTipo = value),
                          validator: (value) =>
                              value == null ? 'Seleccione un tipo' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Tipo de alimentación',
                            controller: tipoAlimentacion,
                            icon: Icons.restaurant,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Cantidad recomendada',
                            controller: cantidadRecomendada,
                            icon: Icons.line_weight,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedFrecuenciaRecomendada,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.schedule),
                            labelText: 'Frecuencia Recomendada',
                          ),
                          items: [
                            '1 vez al día',
                            '2 veces al día',
                            'Cada 2 días',
                            'Semanal',
                          ]
                              .map((f) =>
                                  DropdownMenuItem(value: f, child: Text(f)))
                              .toList(),
                          onChanged: (value) => setState(
                              () => selectedFrecuenciaRecomendada = value),
                          validator: (value) => value == null
                              ? 'Seleccione una frecuencia'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomFormTextField(
                              hintText: 'Seleccionar fecha de rescate',
                              controller: fechaRescateController,
                              icon: Icons.calendar_today,
                              validator: _requiredValidator,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const SizedBox(height: 16),
                        Text('Ubicación del Rescate (toque el mapa):',
                            style: TextStyle(fontWeight: FontWeight.bold)),
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
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Detalle de rescate',
                            controller: detalleRescate,
                            icon: Icons.details,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Imagen del Animal'),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () async {
                                final picked = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                if (picked != null) {
                                  setState(() {
                                    _pickedImage = picked;
                                  });
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
                                        child:
                                            Icon(Icons.add_a_photo, size: 40)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRescatista,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              labelText: 'Nombre del Rescatista'),
                          items: rescatistas
                              .map((r) => DropdownMenuItem(
                                  value: r.nombre, child: Text(r.nombre)))
                              .toList(),
                          onChanged: (value) {
                            final resc = rescatistas
                                .firstWhere((r) => r.nombre == value);
                            setState(() {
                              selectedRescatista = value;
                              selectedTelefono = resc.telefono;
                              selectedFechaRescate = resc.fechaRescatista;
                              selectedUbicacionRescate =
                                  resc.geolocalizacion?.descripcion;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Seleccione un rescatista' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          readOnly: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            labelText: 'Teléfono del Rescatista',
                          ),
                          controller: TextEditingController(
                              text: selectedTelefono ?? ''),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('AGREGAR ANIMAL'),
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
