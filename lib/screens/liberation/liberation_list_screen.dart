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
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 16),
                color: AppColors.primary,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text('Historial de Liberaciones', style: AppTextStyles.heading),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nombre del animal:',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  DropdownButtonFormField<AnimalRescatista>(
                                    decoration: const InputDecoration(border: UnderlineInputBorder()),
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
                                        _liberacion = null;
                                      });
                                      if (value != null) {
                                        _loadLiberacion(value.animal.nombre);
                                      }
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  const Text('Fecha de liberación:',
                                      style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    _formatDate(_liberacion?.fechaLiberacion),
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildRow('Ubicación:', _liberacion?.ubicacionLiberacion),
                                  _buildRow('Observaciones:', _liberacion?.observaciones),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.pushNamed(context, AppRoutes.liberacionForm);
                                if (result == true && _selectedAnimal != null) {
                                  _loadLiberacion(_selectedAnimal!.animal.nombre);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar Liberación'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )
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

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 6, child: Text(value?.isNotEmpty == true ? value! : '-', style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }
}
