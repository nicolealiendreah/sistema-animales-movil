import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/evaluation_model.dart';
import 'package:sistema_animales/servicess/evaluation_service.dart';
import 'evaluation_form_screen.dart';

class MedicalEvaluationScreen extends StatefulWidget {
  final Animal animal;
  final Evaluation? evaluation;

  const MedicalEvaluationScreen({super.key, required this.animal, this.evaluation,});

  @override
  State<MedicalEvaluationScreen> createState() =>
      _MedicalEvaluationScreenState();
}

class _MedicalEvaluationScreenState extends State<MedicalEvaluationScreen> {
  final EvaluationService _evaluationService = EvaluationService();
  Evaluation? _evaluation;
  bool _isLoading = true;
  String? _error;
  

  @override
  void initState() {
    super.initState();
    _loadEvaluation();
  }

  Future<void> _loadEvaluation() async {
    try {
      final evaluations = await _evaluationService.getAll();
      final int animalId = widget.animal.id ?? 0;

      final matching = evaluations.firstWhere(
        (e) => e.animalId == animalId,
        orElse: () => Evaluation(animalId: animalId, diagnostico: ''),
      );

      setState(() {
        _evaluation = matching;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat.yMMMd().format(date);
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '-';
    return DateFormat.jm().format(date);
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 6,
              child: Text(value?.isNotEmpty == true ? value! : '-',
                  style: const TextStyle(color: Colors.black54))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Expanded(
                      child: Text(
                        'Evaluaciones médicas y tratamientos',
                        style: AppTextStyles.heading.copyWith(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${widget.animal.nombre}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(child: Text('Error: $_error'))
                        : Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black12, blurRadius: 6)
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildRow('Diagnóstico:',
                                          _evaluation?.diagnostico),
                                      _buildRow('Síntomas observados:',
                                          _evaluation?.sintomasObservados),
                                      _buildRow('Tratamiento administrado:',
                                          _evaluation?.tratamientoAdministrado),
                                      _buildRow('Medicación recetada:',
                                          _evaluation?.medicacionRecetada),
                                      _buildRow('Veterinario a cargo:',
                                          _evaluation?.veterinario),
                                      const SizedBox(height: 12),
                                      const Text('Fecha de evaluación:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          Text(
                                              _formatDate(
                                                  _evaluation?.fechaEvaluacion),
                                              style: const TextStyle(
                                                  color: Colors.blue)),
                                          const SizedBox(width: 10),
                                          Text(
                                              _formatTime(
                                                  _evaluation?.fechaEvaluacion),
                                              style: const TextStyle(
                                                  color: Colors.blue)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Text('Próxima revisión:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Row(
                                        children: [
                                          Text(
                                              _formatDate(
                                                  _evaluation?.proximaRevision),
                                              style: const TextStyle(
                                                  color: Colors.blue)),
                                          const SizedBox(width: 10),
                                          Text(
                                              _formatTime(
                                                  _evaluation?.proximaRevision),
                                              style: const TextStyle(
                                                  color: Colors.blue)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EvaluationFormScreen(
                                          animal: widget.animal,
                                          evaluation: _evaluation,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar Evaluación'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
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
}
