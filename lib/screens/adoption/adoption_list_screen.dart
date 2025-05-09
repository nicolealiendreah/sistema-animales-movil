import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';
import 'package:sistema_animales/models/adoption_model.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/servicess/adoption_service.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/models/animal_rescatista_model.dart';

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

      setState(() {
        _adoption = match;
      });
    } catch (_) {
      setState(() {
        _adoption = null;
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

  String _formatTime(DateTime? date) =>
      date != null ? DateFormat.jm().format(date) : '-';

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
                    const Text('Historial de Adopciones',
                        style: AppTextStyles.heading),
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
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nombre del animal:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  DropdownButtonFormField<AnimalRescatista>(
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
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
                                  const SizedBox(height: 20),
                                  const Text('Fecha de Adopcion',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Row(
                                    children: [
                                      Text(
                                        _formatDate(_adoption?.fechaAdopcion),
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(_adoption?.fechaAdopcion),
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  _buildRow(
                                      'Estado actual:', _adoption?.estado),
                                  _buildRow('Nombre del adoptante:',
                                      _adoption?.nombreAdoptante),
                                  _buildRow('Contacto del adoptante:',
                                      _adoption?.contactoAdoptante),
                                  _buildRow('Dirección del adoptante:',
                                      _adoption?.direccionAdoptante),
                                  _buildRow('Observaciones:',
                                      _adoption?.observaciones),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.pushNamed(
                                    context, AppRoutes.adoptionForm);
                                if (result == true && _selectedAnimal != null) {
                                  _loadAdoptionData(
                                      _selectedAnimal!.animal.id!);
                                }
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Agregar/Editar Gestión'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 24),
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
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
