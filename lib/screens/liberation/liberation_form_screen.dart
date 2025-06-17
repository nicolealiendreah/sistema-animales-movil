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

class _LiberationFormScreenState extends State<LiberationFormScreen>
    with TickerProviderStateMixin {
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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadAnimals();
    _cargarUbicacionInicial();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaLiberacion = picked;
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : 'Seleccionar fecha';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedAnimal != null) {
      final data = Liberacion(
        id: _liberacion?.id ?? '',
        animalId: _selectedAnimal!.animal.id!,
        nombreAnimal: _selectedAnimal!.animal.nombre,
        ubicacionLiberacion: ubicacionLiberacion.text,
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
          SnackBar(
            content: const Text('Liberación guardada exitosamente'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.transparent,
                  Colors.black.withOpacity(0.05),
                ],
              ),
            ),
          ),
          Column(
            children: [
              _buildModernAppBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildFormContent(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernAppBar() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
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
              'Registrar Liberación',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Información del Animal',
              icon: Icons.pets,
              child: _buildAnimalSelector(),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Ubicación de Liberación',
              icon: Icons.location_on,
              child: _buildMapSection(),
            ),
            const SizedBox(height: 20),
            _buildSectionCard(
              title: 'Detalles Adicionales',
              icon: Icons.description,
              child: Column(
                children: [
                  _buildModernField('Observaciones', observaciones, maxLines: 3),
                  const SizedBox(height: 16),
                  _buildDateSelector(),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildModernSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<AnimalRescatista>(
        value: _selectedAnimal,
        items: _animals.map((animal) {
          return DropdownMenuItem(
            value: animal,
            child: Text(
              animal.animal.nombre,
              style: const TextStyle(fontSize: 16),
            ),
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
        decoration: InputDecoration(
          hintText: 'Seleccionar animal',
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
      ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedPosition ?? LatLng(-17.7832, -63.1817),
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
                        width: 50,
                        height: 50,
                        point: _selectedPosition!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedPosition != null
                      ? 'Lat: ${_selectedPosition!.latitude.toStringAsFixed(5)} - Lng: ${_selectedPosition!.longitude.toStringAsFixed(5)}'
                      : 'Toque el mapa para seleccionar una ubicación',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.shade50,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.calendar_today,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(
          _formatDate(_fechaLiberacion),
          style: TextStyle(
            fontSize: 16,
            color: _fechaLiberacion != null
                ? Colors.grey.shade800
                : Colors.grey.shade500,
          ),
        ),
        trailing: Icon(
          Icons.keyboard_arrow_right,
          color: AppColors.primary,
        ),
        onTap: _pickFechaLiberacion,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildModernField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade50,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'GUARDAR LIBERACIÓN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}