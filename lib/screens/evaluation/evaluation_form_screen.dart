import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/evaluation_model.dart';
import 'package:sistema_animales/servicess/evaluation_service.dart';

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
    if (widget.evaluation != null) {
      diagnostico.text = widget.evaluation!.diagnostico;
      sintomas.text = widget.evaluation!.sintomas ?? '';
      medicacion.text = widget.evaluation!.medicacion ?? '';
      responsable.text = widget.evaluation!.responsable ?? '';
      fechaEvaluacion = widget.evaluation!.fechaEvaluacion;
      proximaRevision = widget.evaluation!.proximaRevision;
    }
  }

  Future<void> _pickDateTime(
      BuildContext context, Function(DateTime) onPicked) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
      responsable: responsable.text,
      fechaEvaluacion: fechaEvaluacion,
      proximaRevision: proximaRevision,
    );

    try {
      await _evaluationService.create(evaluation);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evaluación registrada correctamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar evaluación: $e')),
      );
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
                        'Registrar Evaluación Médica ${widget.animal.nombre}',
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
                        _buildTextField('Diagnóstico', diagnostico),
                        _buildTextField('Síntomas Observados', sintomas),
                        _buildTextField(
                            'Tratamiento Administrado', tratamiento),
                        _buildTextField('Medicación Recetada', medicacion),
                        _buildTextField('responsable a Cargo', responsable),
                        const SizedBox(height: 10),
                        _buildDateTimeRow(
                          'Fecha de Evaluación',
                          fechaEvaluacion,
                          () => _pickDateTime(context,
                              (val) => setState(() => fechaEvaluacion = val)),
                        ),
                        _buildDateTimeRow(
                          'Próxima Revisión',
                          proximaRevision,
                          () => _pickDateTime(context,
                              (val) => setState(() => proximaRevision = val)),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _saveEvaluation,
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

  Widget _buildDateTimeRow(
      String label, DateTime? date, VoidCallback onPressed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            TextButton(
              onPressed: onPressed,
              child: Text(_formatDate(date),
                  style: const TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: onPressed,
              child: Text(_formatTime(date),
                  style: const TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ],
    );
  }
}
