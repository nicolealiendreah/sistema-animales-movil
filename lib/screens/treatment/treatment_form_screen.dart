import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/tratamiento_model.dart';
import 'package:sistema_animales/models/veterinarian_model.dart';
import 'package:sistema_animales/servicess/tratamiento_service.dart';
import 'package:sistema_animales/servicess/veterinario_service.dart';

List<Veterinario> _veterinarios = [];
Veterinario? _selectedVeterinario;
final _veterinarioService = VeterinarioService();

class TreatmentFormScreen extends StatefulWidget {
  final Animal animal;

  const TreatmentFormScreen({super.key, required this.animal});

  @override
  State<TreatmentFormScreen> createState() => _TreatmentFormScreenState();
}

class _TreatmentFormScreenState extends State<TreatmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TratamientoService _TratamientoService = TratamientoService();

  final TextEditingController tratamiento = TextEditingController();
  final TextEditingController responsable = TextEditingController();
  final TextEditingController observaciones = TextEditingController();
  final TextEditingController duracion = TextEditingController();

  DateTime? fechaTratamiento;

  @override
  void initState() {
    super.initState();
    _loadVeterinarios();
  }

  Future<void> _loadVeterinarios() async {
    try {
      final list = await _veterinarioService.getAll();
      setState(() {
        _veterinarios = list;
      });
    } catch (e) {
      print('Error al cargar veterinarios: $e');
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: fechaTratamiento ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      setState(() => fechaTratamiento = date);
    }
  }

  Future<void> _saveTreatment() async {
    if (!_formKey.currentState!.validate()) return;

    final treatment = Tratamiento(
      nombreAnimal: widget.animal.nombre,
      tratamiento: tratamiento.text,
      fechaTratamiento: fechaTratamiento,
      responsable: _selectedVeterinario?.nombre ?? '',
      observaciones: observaciones.text,
      duracion: duracion.text,
    );

    try {
      await _TratamientoService.create(treatment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tratamiento registrado correctamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar tratamiento: $e')),
      );
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

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
                color: AppColors.primary,
                padding: const EdgeInsets.only(top: 50, bottom: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'Registrar Tratamiento ${widget.animal.nombre}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                        _buildTextField('Tratamiento', tratamiento),
                        DropdownButtonFormField<Veterinario>(
                          value: _selectedVeterinario,
                          items: _veterinarios.map((v) {
                            return DropdownMenuItem(
                              value: v,
                              child: Text(v.nombre),
                            );
                          }).toList(),
                          onChanged: (v) {
                            setState(() => _selectedVeterinario = v);
                          },
                          decoration: const InputDecoration(
                            labelText: 'Veterinario responsable',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null
                              ? 'Seleccione un veterinario'
                              : null,
                        ),
                        _buildTextField('Observaciones', observaciones),
                        _buildTextField('Duración', duracion),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Fecha del tratamiento:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () => _pickDate(context),
                              child: Text(
                                _formatDate(fechaTratamiento),
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveTreatment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('GUARDAR'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
