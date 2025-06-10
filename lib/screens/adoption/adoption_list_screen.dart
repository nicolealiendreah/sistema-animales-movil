import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';
import 'package:sistema_animales/models/adoption_model.dart';
import 'package:sistema_animales/servicess/adoption_service.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/models/animal_rescatista_model.dart';
import 'package:geocoding/geocoding.dart';

class AdoptionListScreen extends StatefulWidget {
  const AdoptionListScreen({super.key});

  @override
  State<AdoptionListScreen> createState() => _AdoptionListScreenState();
}

class _AdoptionListScreenState extends State<AdoptionListScreen> {
  final AdoptionService _adoptionService = AdoptionService();
  final AnimalService _animalService = AnimalService();

  List<AnimalRescatista> _animals = [];
  AnimalRescatista? _selectedAnimal;
  Adoption? _adoption;

  bool _isLoading = true;
  String? _direccionEstimacion;

  @override
  void initState() {
    super.initState();
    _loadAnimalsAndAdoptions();
  }

  Future<void> _loadAnimalsAndAdoptions() async {
    try {
      final animals = await _animalService.getAll();
      setState(() {
        _animals = animals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAdoptionData(String nombreAnimal) async {
    try {
      final adoptions = await _adoptionService.getAll();
      final match = adoptions.firstWhere((a) => a.nombreAnimal == nombreAnimal);

      String? direccion = match.direccionAdoptante;

      if ((direccion == null || direccion.trim().isEmpty) &&
          match.latitud != null &&
          match.longitud != null) {
        try {
          final placemarks =
              await placemarkFromCoordinates(match.latitud!, match.longitud!);
          if (placemarks.isNotEmpty) {
            final p = placemarks.first;
            direccion = '${p.street ?? ''}, ${p.locality ?? ''}';
          } else {
            direccion = 'Ubicación estimada no disponible';
          }
        } catch (_) {
          direccion = 'Ubicación estimada no disponible';
        }
      }

      setState(() {
        _adoption = match;
        _direccionEstimacion = direccion;
      });
    } catch (_) {
      setState(() {
        _adoption = null;
        _direccionEstimacion = null;
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

  String _formatTime(DateTime? date) =>
      date != null ? DateFormat.jm().format(date) : '-';

  String _getDireccionText() {
    if (_adoption == null) {
      return '';
    }
    final desc = _adoption!.direccionAdoptante;
    return (desc != null && desc.isNotEmpty) ? desc : 'Ubicación Seleccionada';
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'adoptado':
        return Colors.green;
      case 'en proceso':
        return Colors.orange;
      case 'pendiente':
        return Colors.blue;
      default:
        return Colors.grey;
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
                  color: AppColors.primary.withOpacity(0.95),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Historial de Adopciones',
                              style: AppTextStyles.heading),
                          Text(
                            'Gestiona y consulta las adopciones',
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
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando adopciones...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.05),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.pets,
                                              color: AppColors.primary,
                                              size: 24,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Seleccionar Animal',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          child: DropdownButtonFormField<AnimalRescatista>(
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 12,
                                              ),
                                            ),
                                            value: _selectedAnimal,
                                            hint: const Text('Seleccionar animal'),
                                            items: _animals
                                                .map((ar) => DropdownMenuItem(
                                                      value: ar,
                                                      child: Text(ar.animal.nombre),
                                                    ))
                                                .toList(),
                                            onChanged: (value) {
                                              setState(() {
                                                _selectedAnimal = value;
                                                _adoption = null;
                                              });
                                              if (value != null) {
                                                _loadAdoptionData(value.animal.nombre);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  if (_adoption != null)
                                    Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(_adoption?.estado)
                                                  .withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _getStatusColor(_adoption?.estado)
                                                    .withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Fecha de Adopción',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.grey.shade600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            Icons.calendar_today,
                                                            size: 16,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            _formatDate(_adoption?.fechaAdopcion),
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Icon(
                                                            Icons.access_time,
                                                            size: 16,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            _formatTime(_adoption?.fechaAdopcion),
                                                            style: const TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(_adoption?.estado),
                                                    borderRadius: BorderRadius.circular(20),
                                                  ),
                                                  child: Text(
                                                    _adoption?.estado ?? 'Sin estado',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 20),
                                          
                                          _buildModernInfoCard(
                                            'Información del Adoptante',
                                            Icons.person,
                                            [
                                              _buildInfoRow(
                                                'Nombre',
                                                _adoption?.nombreAdoptante,
                                                Icons.person_outline,
                                              ),
                                              _buildInfoRow(
                                                'Contacto',
                                                _adoption?.contactoAdoptante,
                                                Icons.phone,
                                              ),
                                              _buildInfoRow(
                                                'Dirección',
                                                _getDireccionText(),
                                                Icons.location_on,
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 16),
                                          
                                          if (_adoption?.observaciones?.isNotEmpty == true)
                                            _buildModernInfoCard(
                                              'Observaciones',
                                              Icons.note,
                                              [
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade50,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    _adoption?.observaciones ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      height: 1.4,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                    context, AppRoutes.adoptionForm);
                                if (result == true && _selectedAnimal != null) {
                                  _loadAdoptionData(
                                      _selectedAnimal!.animal.nombre);
                                }
                              },
                              icon: const Icon(Icons.add, size: 24),
                              label: const Text(
                                'Agregar Nueva Adopción',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 56),
                                elevation: 8,
                                shadowColor: AppColors.primary.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
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

  Widget _buildModernInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value?.isNotEmpty == true ? value! : 'No especificado',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}