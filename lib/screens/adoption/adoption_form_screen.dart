import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/adoption_model.dart';
import 'package:sistema_animales/servicess/adoption_service.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/models/animal_rescatista_model.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

class AdoptionFormScreen extends StatefulWidget {
  const AdoptionFormScreen({super.key});

  @override
  State<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen>
    with TickerProviderStateMixin {
  final AdoptionService _adoptionService = AdoptionService();
  final AnimalService _animalService = AnimalService();
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<AnimalRescatista> _animals = [];
  AnimalRescatista? _selectedAnimal;
  Adoption? _adoption;
  DateTime? _fechaAdopcion;
  LatLng? _selectedPosition;
  MapController _mapController = MapController();
  String? estadoSeleccionado;

  final TextEditingController estado = TextEditingController();
  final TextEditingController nombreAdoptante = TextEditingController();
  final TextEditingController contactoAdoptante = TextEditingController();
  final TextEditingController direccionAdoptante = TextEditingController();
  final TextEditingController observaciones = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadAnimals();
    _cargarUbicacionInicial();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  Future<void> _loadAnimals() async {
    final allAnimals = await _animalService.getAll();
    final domesticAnimals =
        allAnimals.where((a) => a.animal.tipo == 'Doméstico').toList();
    setState(() {
      _animals = domesticAnimals;
    });
  }

  Future<void> _loadAdoption(String nombreAnimal) async {
    try {
      final adoptions = await _adoptionService.getAll();
      final match = adoptions.firstWhere((a) => a.nombreAnimal == nombreAnimal);

      setState(() {
        _adoption = match;
        estado.text = match.estado ?? '';
        nombreAdoptante.text = match.nombreAdoptante ?? '';
        contactoAdoptante.text = match.contactoAdoptante ?? '';
        direccionAdoptante.text = match.direccionAdoptante ?? '';
        observaciones.text = match.observaciones ?? '';
        _fechaAdopcion = match.fechaAdopcion;
      });
    } catch (_) {
      setState(() {
        _adoption = null;
        estado.clear();
        nombreAdoptante.clear();
        contactoAdoptante.clear();
        direccionAdoptante.clear();
        observaciones.clear();
        _fechaAdopcion = null;
      });
    }
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
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
    if (time == null) return;

    setState(() {
      _fechaAdopcion =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : 'Seleccionar fecha';

  String _formatTime(DateTime? date) =>
      date != null ? DateFormat.jm().format(date) : '-';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAnimal == null) {
      _showSnackBar('Debe seleccionar un animal', Icons.warning, Colors.orange);
      return;
    }

    try {
      final adoption = Adoption(
        nombreAnimal: _selectedAnimal!.animal.nombre,
        estado: estadoSeleccionado ?? estado.text,
        nombreAdoptante: nombreAdoptante.text,
        contactoAdoptante: contactoAdoptante.text,
        direccionAdoptante: direccionAdoptante.text,
        observaciones: observaciones.text,
        fechaAdopcion: _fechaAdopcion ?? DateTime.now(),
        latitud: _selectedPosition?.latitude,
        longitud: _selectedPosition?.longitude,
        descripcion: direccionAdoptante.text.isNotEmpty
            ? direccionAdoptante.text
            : 'Ubicación seleccionada',
      );

      await _adoptionService.create(adoption);
      if (!mounted) return;
      _showSnackBar(
          'Adopción guardada exitosamente', Icons.check_circle, Colors.green);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error al guardar: $e', Icons.error, Colors.red);
    }
  }

  void _showSnackBar(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
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
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Container(
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
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_rounded,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Historial de Adopciones',
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
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Información del Animal'),
                                const SizedBox(height: 16),
                                _buildModernDropdown<AnimalRescatista>(
                                  value: _selectedAnimal,
                                  items: _animals,
                                  hint: 'Seleccionar animal',
                                  itemBuilder: (animal) => animal.animal.nombre,
                                  onChanged: (AnimalRescatista? animal) {
                                    if (animal != null) {
                                      setState(() {
                                        _selectedAnimal = animal;
                                      });
                                      _loadAdoption(animal.animal.id!);
                                    }
                                  },
                                  icon: Icons.pets,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Estado de Adopción'),
                                const SizedBox(height: 16),
                                _buildStatusDropdown(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Datos del Adoptante'),
                                const SizedBox(height: 16),
                                _buildModernField(
                                  'Nombre completo',
                                  nombreAdoptante,
                                  icon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty)
                                      return 'Campo requerido';
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildModernField(
                                  'Número de contacto',
                                  contactoAdoptante,
                                  icon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.isEmpty)
                                      return 'Campo requerido';
                                    if (!RegExp(r'^\d+$').hasMatch(value))
                                      return 'Solo se permiten números';
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Ubicación del Adoptante'),
                                const SizedBox(height: 8),
                                Text(
                                  'Toque en el mapa para seleccionar la ubicación',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildModernMap(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildModernCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle('Información Adicional'),
                                const SizedBox(height: 16),
                                _buildModernField(
                                  'Observaciones',
                                  observaciones,
                                  icon: Icons.notes_outlined,
                                  maxLines: 4,
                                  validator: null,
                                ),
                                const SizedBox(height: 16),
                                _buildDateSection(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildModernSubmitButton(),
                          const SizedBox(height: 20),
                        ],
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

  Widget _buildModernCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildModernField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? Function(String?)? validator,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator:
              validator ?? (value) => value!.isEmpty ? 'Campo requerido' : null,
          decoration: InputDecoration(
            prefixIcon:
                icon != null ? Icon(icon, color: AppColors.primary) : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildModernDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.primary) : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(itemBuilder(item)),
          );
        }).toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: estadoSeleccionado,
        decoration: InputDecoration(
          prefixIcon:
              Icon(Icons.track_changes_outlined, color: AppColors.primary),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: 'Seleccionar estado',
          hintStyle: TextStyle(color: Colors.grey[600]),
        ),
        items: ['Adoptado', 'En seguimiento', 'Pendiente'].map((estado) {
          Color statusColor = estado == 'Adoptado'
              ? Colors.green
              : estado == 'En seguimiento'
                  ? Colors.orange
                  : Colors.blue;

          return DropdownMenuItem(
            value: estado,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(estado),
              ],
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            estadoSeleccionado = value;
          });
        },
        validator: (value) {
          const validStates = ['Adoptado', 'En seguimiento', 'Pendiente'];
          if (value == null || value.isEmpty) return 'Campo requerido';
          if (!validStates.contains(value)) return 'Estado no válido';
          return null;
        },
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildModernMap() {
    return Container(
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
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                        Icons.location_on,
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
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha de adopción',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _pickDateTime,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined, color: AppColors.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _formatDate(_fechaAdopcion),
                    style: TextStyle(
                      fontSize: 16,
                      color: _fechaAdopcion != null
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernSubmitButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: const Text(
          'GUARDAR ADOPCIÓN',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
