import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _AnimalFormScreenState extends State<AnimalFormScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _service = AnimalService();
  final _rescuerService = RescuerService();
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _ubicacionSeleccionadaPorUsuario = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  @override
  void initState() {
    super.initState();
    _loadRescatistas();
    _cargarUbicacionInicial();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaRescate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
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
    try {
      if (!_formKey.currentState!.validate()) {
        _showSnackBar('Por favor, complete todos los campos obligatorios',
            isError: true);
        return;
      }

      if (_pickedImage == null) {
        throw 'Debe seleccionar una imagen del animal';
      }

      final extension = _pickedImage!.path.split('.').last.toLowerCase();
      const allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
      if (!allowedExtensions.contains(extension)) {
        throw 'Solo se permiten imágenes JPG, PNG o GIF';
      }

      if (_selectedPosition == null || !_ubicacionSeleccionadaPorUsuario) {
        throw 'Debe seleccionar manualmente una ubicación en el mapa';
      }

      if (selectedRescatista == null) {
        throw 'Seleccione un rescatista';
      }

      final selectedRescuer = rescatistas.firstWhere(
        (r) => r.nombre == selectedRescatista,
        orElse: () => throw Exception('Rescatista no encontrado'),
      );

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

      final success = await _service.create(data, imageFile: _pickedImage);

      if (!mounted) return;

      if (success) {
        _showSnackBar('Animal registrado exitosamente', isError: false);
        Navigator.pop(context, true);
      } else {
        throw 'Error al registrar animal';
      }
    } catch (e) {
      _showSnackBar(e.toString(), isError: true);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  InputDecoration buildFieldDecoration(IconData icon, String label) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.95),
      prefixIcon: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registro de Animal',
                            style: AppTextStyles.heading.copyWith(fontSize: 22),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Complete la información del rescate',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Información Básica'),
                                CustomFormTextField(
                                  hintText: 'Nombre del animal',
                                  controller: nombre,
                                  icon: Icons.pets,
                                  validator: _requiredValidator,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomFormTextField(
                                        hintText: 'Especie',
                                        controller: especie,
                                        icon: Icons.category,
                                        validator: _requiredValidator,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomFormTextField(
                                        hintText: 'Raza',
                                        controller: raza,
                                        icon: Icons.pets,
                                        validator: _requiredValidator,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: selectedSexo,
                                        decoration: buildFieldDecoration(
                                            Icons.transgender, 'Sexo'),
                                        items: ['Macho', 'Hembra']
                                            .map((sexo) => DropdownMenuItem(
                                                value: sexo, child: Text(sexo)))
                                            .toList(),
                                        onChanged: (value) => setState(
                                            () => selectedSexo = value),
                                        validator: (value) => value == null
                                            ? 'Seleccione un sexo'
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomFormTextField(
                                        hintText: 'Edad',
                                        controller: edad,
                                        icon: Icons.cake,
                                        validator: _requiredValidator,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: selectedEstadoSalud,
                                  decoration: buildFieldDecoration(
                                      Icons.health_and_safety,
                                      'Estado de Salud'),
                                  items: [
                                    'Excelente',
                                    'Bueno',
                                    'Regular',
                                    'Crítico'
                                  ]
                                      .map((estado) => DropdownMenuItem(
                                          value: estado, child: Text(estado)))
                                      .toList(),
                                  onChanged: (value) => setState(
                                      () => selectedEstadoSalud = value),
                                  validator: (value) => value == null
                                      ? 'Seleccione un estado de salud'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: selectedTipo,
                                  decoration: buildFieldDecoration(
                                      Icons.nature, 'Tipo del Animal'),
                                  items: ['Silvestre', 'Doméstico']
                                      .map((tipo) => DropdownMenuItem(
                                          value: tipo, child: Text(tipo)))
                                      .toList(),
                                  onChanged: (value) =>
                                      setState(() => selectedTipo = value),
                                  validator: (value) => value == null
                                      ? 'Seleccione un tipo'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Alimentación'),
                                CustomFormTextField(
                                  hintText: 'Tipo de alimentación',
                                  controller: tipoAlimentacion,
                                  icon: Icons.restaurant,
                                  validator: _requiredValidator,
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomFormTextField(
                                        hintText: 'Cantidad recomendada',
                                        controller: cantidadRecomendada,
                                        icon: Icons.line_weight,
                                        validator: _requiredValidator,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      child: DropdownButtonFormField<String>(
                                        isExpanded:
                                            true,
                                        value: selectedFrecuenciaRecomendada,
                                        decoration: buildFieldDecoration(
                                            Icons.schedule, 'Frecuencia'),
                                        items: [
                                          '1 vez al día',
                                          '2 veces al día',
                                          'Cada 2 días',
                                          'Semanal'
                                        ]
                                            .map((f) => DropdownMenuItem(
                                                value: f, child: Text(f)))
                                            .toList(),
                                        onChanged: (value) => setState(() =>
                                            selectedFrecuenciaRecomendada =
                                                value),
                                        validator: (value) => value == null
                                            ? 'Seleccione una frecuencia'
                                            : null,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Información del Rescate'),
                                GestureDetector(
                                  onTap: () => _selectDate(context),
                                  child: AbsorbPointer(
                                    child: CustomFormTextField(
                                      hintText: 'Fecha de rescate',
                                      controller: fechaRescateController,
                                      icon: Icons.calendar_today,
                                      validator: _requiredValidator,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Ubicación del Rescate',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 200,
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
                                            _ubicacionSeleccionadaPorUsuario =
                                                true;
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
                                                child: const Icon(
                                                    Icons.location_pin,
                                                    size: 40,
                                                    color: Colors.red),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                CustomFormTextField(
                                  hintText: 'Detalle del rescate',
                                  controller: detalleRescate,
                                  icon: Icons.description,
                                  validator: _requiredValidator,
                                ),
                              ],
                            ),
                          ),
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Imagen del Animal'),
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
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                          color: Colors.grey.shade300,
                                          style: BorderStyle.solid),
                                    ),
                                    child: _pickedImage != null
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            child: Image.file(
                                              File(_pickedImage!.path),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: const Icon(
                                                  Icons.add_a_photo,
                                                  size: 40,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                'Toca para seleccionar imagen',
                                                style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 14),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Datos del Rescatista'),
                                DropdownButtonFormField<String>(
                                  value: selectedRescatista,
                                  decoration: buildFieldDecoration(
                                      Icons.person, 'Nombre del Rescatista'),
                                  items: rescatistas
                                      .map((r) => DropdownMenuItem(
                                          value: r.nombre,
                                          child: Text(r.nombre)))
                                      .toList(),
                                  onChanged: (value) {
                                    final resc = rescatistas.firstWhere(
                                        (r) => r.nombre == value,
                                        orElse: () => rescatistas.first);
                                    setState(() {
                                      selectedRescatista = value;
                                      selectedTelefono = resc.telefono;
                                      selectedFechaRescate =
                                          resc.fechaRescatista;
                                      selectedUbicacionRescate =
                                          resc.geolocalizacion?.descripcion;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Seleccione un rescatista'
                                      : null,
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  readOnly: true,
                                  controller: TextEditingController(
                                      text: selectedTelefono ?? ''),
                                  decoration: buildFieldDecoration(
                                      Icons.phone, 'Teléfono del Rescatista'),
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 20),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 8,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.save, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'REGISTRAR ANIMAL',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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
