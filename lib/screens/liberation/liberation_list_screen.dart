import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';
import 'package:sistema_animales/models/animal_rescatista_model.dart';
import 'package:sistema_animales/models/liberacion_model.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/servicess/liberacion_service.dart';

class LiberationListScreen extends StatefulWidget {
  const LiberationListScreen({super.key});

  @override
  State<LiberationListScreen> createState() => _LiberationListScreenState();
}

class _LiberationListScreenState extends State<LiberationListScreen> {
  final AnimalService _animalService = AnimalService();
  final LiberacionService _liberacionService = LiberacionService();

  List<AnimalRescatista> _animals = [];
  AnimalRescatista? _selectedAnimal;
  Liberacion? _liberacion;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    try {
      final list = await _animalService.getAll();
      setState(() {
        _animals = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLiberacion(String nombreAnimal) async {
    try {
      final list = await _liberacionService.getAll();
      final match = list.firstWhere((l) => l.nombreAnimal == nombreAnimal);
      setState(() => _liberacion = match);
    } catch (_) {
      setState(() => _liberacion = null);
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    final date = DateTime.tryParse(isoDate);
    return date != null ? DateFormat.yMMMd().format(date) : '-';
  }

  String _getUbicacionText() {
    if (_liberacion == null) {
      return '';
    }
    final desc = _liberacion!.descripcion;
    return (desc != null && desc.isNotEmpty) ? desc : 'Ubicación Seleccionada';
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
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.9),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 22),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Historial de Liberaciones',
                              style: AppTextStyles.heading),
                          Text(
                            'Consulta y registra las liberaciones',
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
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando información...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
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
                                    offset: const Offset(0, 10),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          child: Icon(
                                            Icons.pets_rounded,
                                            color: AppColors.primary,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Seleccionar Animal',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey[300]!),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonFormField<
                                          AnimalRescatista>(
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                          hintText: 'Seleccionar animal',
                                          hintStyle: TextStyle(
                                              color: Colors.grey[500]),
                                        ),
                                        value: _selectedAnimal,
                                        icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: AppColors.primary),
                                        items: _animals
                                            .map((ar) => DropdownMenuItem(
                                                  value: ar,
                                                  child: Text(
                                                    ar.animal.nombre,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedAnimal = value;
                                            _liberacion = null;
                                          });
                                          if (value != null) {
                                            _loadLiberacion(
                                                value.animal.nombre);
                                          }
                                        },
                                      ),
                                    ),
                                    if (_selectedAnimal != null) ...[
                                      const SizedBox(height: 32),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.grey[200]!),
                                        ),
                                        child: Column(
                                          children: [
                                            _buildModernInfoRow(
                                              Icons.calendar_today_rounded,
                                              'Fecha de liberación',
                                              _formatDate(
                                                  _liberacion?.fechaLiberacion),
                                            ),
                                            const SizedBox(height: 16),
                                            _buildModernInfoRow(
                                              Icons.location_on_rounded,
                                              'Ubicación',
                                              _getUbicacionText(),
                                            ),
                                            const SizedBox(height: 16),
                                            _buildModernInfoRow(
                                              Icons.note_alt_rounded,
                                              'Observaciones',
                                              _liberacion?.observaciones,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.8)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () async {
                                    final result = await Navigator.pushNamed(
                                        context, AppRoutes.liberacionForm);
                                    if (result == true &&
                                        _selectedAnimal != null) {
                                      _loadLiberacion(
                                          _selectedAnimal!.animal.nombre);
                                    }
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Agregar Liberación',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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

  Widget _buildModernInfoRow(IconData icon, String label, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value?.isNotEmpty == true ? value! : '-',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
