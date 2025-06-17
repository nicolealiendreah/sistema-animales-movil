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
  bool _ubicacionSeleccionadaPorUsuario = false;

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.light,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaRescatista = picked;
        _fechaController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _guardarRescatista() async {
    try {
      if (!_formKey.currentState!.validate() || _fechaRescatista == null) {
        _showModernSnackbar('Complete todos los campos obligatorios', Icons.warning_amber_rounded);
        return;
      }

      if (_pickedImage == null) {
        _showModernSnackbar('Debe seleccionar una imagen del rescatista', Icons.image_not_supported_outlined);
        return;
      }

      final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
      final extension = _pickedImage!.path.split('.').last.toLowerCase();

      if (!allowedExtensions.contains(extension)) {
        _showModernSnackbar('Solo se permiten imágenes JPG, PNG o GIF', Icons.error_outline);
        return;
      }

      if (_selectedPosition == null || !_ubicacionSeleccionadaPorUsuario) {
        _showModernSnackbar('Debe seleccionar una ubicación en el mapa', Icons.location_off);
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

      await _rescuerService.create(nuevo, imageFile: _pickedImage);

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      _showModernSnackbar('Error inesperado: $e', Icons.error);
    }
  }

  void _showModernSnackbar(String message, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
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
        _showModernSnackbar('Permiso de ubicación denegado', Icons.location_disabled);
        return;
      }

      final posicion = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedPosition =
            latlng.LatLng(posicion.latitude, posicion.longitude);
        _isMapReady = true;
      });
    } catch (e) {
      _showModernSnackbar('Error al obtener ubicación: $e', Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
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
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
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
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Registrar Rescatista',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.person_add,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Datos del Rescatista',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildModernTextField(
                              controller: _nombreController,
                              hint: 'Nombre completo',
                              icon: Icons.person_outline,
                              validator: _requiredValidator,
                            ),
                            const SizedBox(height: 20),
                            _buildModernTextField(
                              controller: _telefonoController,
                              hint: 'Número de teléfono',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Este campo es obligatorio';
                                }
                                if (!RegExp(r'^\d+$').hasMatch(value)) {
                                  return 'Solo se permiten números';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () => _selectfechaRescatista(context),
                              child: AbsorbPointer(
                                child: _buildModernTextField(
                                  controller: _fechaController,
                                  hint: 'Fecha de nacimiento',
                                  icon: Icons.calendar_month_outlined,
                                  validator: _requiredValidator,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.location_on_outlined,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Ubicación del rescatista',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: _selectedPosition ??
                                      latlng.LatLng(-17.7832, -63.1817),
                                  initialZoom: 15,
                                  onTap: (tapPosition, point) {
                                    setState(() {
                                      _selectedPosition = point;
                                      _ubicacionSeleccionadaPorUsuario = true;
                                    });
                                    HapticFeedback.lightImpact();
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
                                              shape: BoxShape.circle,
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
                                              color: Colors.white,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.photo_camera_outlined,
                                      color: AppColors.primary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Imagen del Rescatista',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
                                      _showModernSnackbar('Solo se permiten imágenes JPG, PNG o GIF', Icons.error_outline);
                                      return;
                                    }

                                    setState(() {
                                      _pickedImage = picked;
                                    });
                                    HapticFeedback.lightImpact();
                                  }
                                } catch (e) {
                                  _showModernSnackbar('Error al seleccionar imagen: $e', Icons.error);
                                }
                              },
                              child: Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: _pickedImage != null 
                                      ? Colors.transparent 
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _pickedImage != null 
                                        ? AppColors.primary.withOpacity(0.3)
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: _pickedImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            Image.file(
                                              File(_pickedImage!.path),
                                              fit: BoxFit.cover,
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topRight,
                                                  end: Alignment.bottomLeft,
                                                  colors: [
                                                    Colors.black.withOpacity(0.3),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Positioned(
                                              top: 12,
                                              right: 12,
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 32,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppColors.primary.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.add_a_photo_outlined,
                                              size: 48,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Toca para seleccionar imagen',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey.shade600,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _guardarRescatista,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.save_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Guardar Rescatista',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          errorStyle: const TextStyle(
            color: Colors.red,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}