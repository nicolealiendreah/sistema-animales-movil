import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/evaluation_model.dart';
import 'package:sistema_animales/models/veterinarian_model.dart';
import 'package:sistema_animales/servicess/evaluation_service.dart';
import 'package:sistema_animales/servicess/veterinario_service.dart';

List<Veterinario> _veterinarios = [];
String? _selectedVeterinarioId;
Veterinario? _selectedVeterinario;

final _veterinarioService = VeterinarioService();

class EvaluationFormScreen extends StatefulWidget {
  final Animal animal;
  final Evaluation? evaluation;

  const EvaluationFormScreen({
    super.key,
    required this.animal,
    this.evaluation,
  });

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final EvaluationService _evaluationService = EvaluationService();

  final TextEditingController diagnostico = TextEditingController();
  final TextEditingController sintomas = TextEditingController();
  final TextEditingController tratamiento = TextEditingController();
  final TextEditingController medicacion = TextEditingController();
  final TextEditingController responsable = TextEditingController();

  DateTime? fechaEvaluacion;
  DateTime? proximaRevision;

  @override
  void initState() {
    super.initState();
    _loadVeterinarios();
    diagnostico.clear();
    sintomas.clear();
    tratamiento.clear();
    medicacion.clear();
    responsable.clear();
    fechaEvaluacion = null;
    proximaRevision = null;
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

  Future<void> _pickDateTime(
      BuildContext context, Function(DateTime) onPicked) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
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

    final dateTime =
        DateTime(date.year, date.month, date.day, time.hour, time.minute);
    onPicked(dateTime);
  }

  Future<void> _saveEvaluation() async {
    if (!_formKey.currentState!.validate()) return;

    final evaluation = Evaluation(
      nombreAnimal: widget.animal.nombre,
      diagnostico: diagnostico.text,
      sintomas: sintomas.text,
      medicacion: medicacion.text,
      responsable: _selectedVeterinario?.nombre ?? '',
      fechaEvaluacion: fechaEvaluacion,
      proximaRevision: proximaRevision,
    );

    try {
      await _evaluationService.create(evaluation);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Evaluación registrada correctamente'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar evaluación: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : 'Seleccionar fecha';

  String _formatTime(DateTime? date) =>
      date != null ? DateFormat.jm().format(date) : 'Seleccionar hora';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Text(
            'Evaluación Médica - ${widget.animal.nombre}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        centerTitle: true,
      ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información Médica',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildModernTextField('Diagnóstico', diagnostico, Icons.medical_services_outlined),
                      _buildModernTextField('Síntomas Observados', sintomas, Icons.visibility_outlined),
                      _buildModernTextField('Tratamiento Administrado', tratamiento, Icons.healing_outlined),
                      _buildModernTextField('Medicación Recetada', medicacion, Icons.medication_outlined),
                      
                      const SizedBox(height: 16),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedVeterinario?.id,
                          items: _veterinarios.map((v) {
                            return DropdownMenuItem(
                              value: v.id,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(v.nombre),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (idSeleccionado) {
                            setState(() {
                              _selectedVeterinario = _veterinarios
                                  .firstWhere((v) => v.id == idSeleccionado);
                            });
                          },
                          decoration: InputDecoration(
                            labelText: 'Veterinario responsable',
                            prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            labelStyle: TextStyle(color: Colors.grey.shade600),
                          ),
                          validator: (value) => value == null
                              ? 'Seleccione un veterinario'
                              : null,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'Fechas Importantes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildModernDateTimeCard(
                        'Fecha de Evaluación',
                        fechaEvaluacion,
                        Icons.calendar_today_outlined,
                        () => _pickDateTime(context, (val) => setState(() => fechaEvaluacion = val)),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      _buildModernDateTimeCard(
                        'Próxima Revisión',
                        proximaRevision,
                        Icons.schedule_outlined,
                        () => _pickDateTime(context, (val) => setState(() => proximaRevision = val)),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveEvaluation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.save_outlined, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'GUARDAR EVALUACIÓN',
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
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextFormField(
          controller: controller,
          validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
          maxLines: label.contains('Síntomas') || label.contains('Tratamiento') ? 3 : 1,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            labelStyle: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  Widget _buildModernDateTimeCard(String label, DateTime? date, IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatDate(date)} • ${_formatTime(date)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: date != null ? Colors.black87 : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}