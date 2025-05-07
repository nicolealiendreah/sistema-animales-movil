import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/adoption_model.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/servicess/adoption_service.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/models/animal_rescatista_model.dart';

class AdoptionFormScreen extends StatefulWidget {
  const AdoptionFormScreen({super.key});

  @override
  State<AdoptionFormScreen> createState() => _AdoptionFormScreenState();
}

class _AdoptionFormScreenState extends State<AdoptionFormScreen> {
  final AdoptionService _adoptionService = AdoptionService();
  final AnimalService _animalService = AnimalService();
  final _formKey = GlobalKey<FormState>();

  List<AnimalRescatista> _animals = [];
  AnimalRescatista? _selectedAnimal;
  Adoption? _adoption;
  DateTime? _fechaAdopcion;

  final TextEditingController estado = TextEditingController();
  final TextEditingController nombreAdoptante = TextEditingController();
  final TextEditingController contactoAdoptante = TextEditingController();
  final TextEditingController direccionAdoptante = TextEditingController();
  final TextEditingController observaciones = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAnimals();
  }

  Future<void> _loadAnimals() async {
    final animals = await _animalService.getAll();
    setState(() {
      _animals = animals;
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
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _fechaAdopcion =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

  String _formatTime(DateTime? date) =>
      date != null ? DateFormat.jm().format(date) : '-';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _selectedAnimal != null) {
      final adoption = Adoption(
        nombreAnimal: _selectedAnimal!.animal.nombre,
        estado: estado.text,
        nombreAdoptante: nombreAdoptante.text,
        contactoAdoptante: contactoAdoptante.text,
        direccionAdoptante: direccionAdoptante.text,
        observaciones: observaciones.text,
        fechaAdopcion: _fechaAdopcion ?? DateTime.now(),
      );

      try {
        await _adoptionService.create(adoption);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adopción guardada')),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Nombre del animal:',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        DropdownButtonFormField<AnimalRescatista>(
                          value: _selectedAnimal,
                          items: _animals.map((animal) {
                            return DropdownMenuItem(
                              value: animal,
                              child: Text(animal.animal.nombre),
                            );
                          }).toList(),
                          onChanged: (AnimalRescatista? animal) {
                            if (animal != null) {
                              setState(() {
                                _selectedAnimal = animal;
                              });
                              _loadAdoption(animal.animal.id!);
                            }
                          },
                          decoration: const InputDecoration(
                            hintText: 'Nombre Animal',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildField('Estado actual', estado),
                        _buildField('Nombre del adoptante', nombreAdoptante),
                        _buildField(
                            'Contacto del adoptante', contactoAdoptante),
                        _buildField(
                            'Dirección del adoptante', direccionAdoptante),
                        _buildField('Observaciones', observaciones,
                            maxLines: 3),
                        const SizedBox(height: 12),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Fecha de rescate/liberación',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _pickDateTime,
                              child: Text(_formatDate(_fechaAdopcion),
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                            TextButton(
                              onPressed: _pickDateTime,
                              child: Text(_formatTime(_fechaAdopcion),
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('GUARDAR'),
                        ),
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

  Widget _buildField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}
