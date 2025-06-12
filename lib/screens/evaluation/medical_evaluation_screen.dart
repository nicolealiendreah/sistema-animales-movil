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

  const MedicalEvaluationScreen({
    super.key,
    required this.animal,
    this.evaluation,
  });

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
      final String animalId = widget.animal.id.toString();

      final matching = evaluations.firstWhere(
        (e) => e.nombreAnimal == widget.animal.nombre,
        orElse: () =>
            Evaluation(nombreAnimal: widget.animal.nombre, diagnostico: ''),
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

  Widget _buildInfoCard(
      String title, String? value, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value?.isNotEmpty == true ? value! : 'No especificado',
                  style: TextStyle(
                    fontSize: 15,
                    color: value?.isNotEmpty == true
                        ? Colors.black
                        : Colors.grey.shade500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateCard(String title, DateTime? date, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  _formatTime(date),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Evaluaciones médicas',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pets, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            widget.animal.nombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.white,
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
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const CircularProgressIndicator(),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Text(
                                'Error: $_error',
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildInfoCard(
                                  'Diagnóstico',
                                  _evaluation?.diagnostico,
                                  Icons.medical_services,
                                  Colors.red.shade400,
                                ),
                                _buildInfoCard(
                                  'Síntomas observados',
                                  _evaluation?.sintomas,
                                  Icons.visibility,
                                  Colors.orange.shade400,
                                ),
                                _buildInfoCard(
                                  'Medicación recetada',
                                  _evaluation?.medicacion,
                                  Icons.medication,
                                  Colors.green.shade400,
                                ),
                                _buildInfoCard(
                                  'Responsable a cargo',
                                  _evaluation?.responsable,
                                  Icons.person,
                                  Colors.blue.shade400,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateCard(
                                        'Fecha de evaluación',
                                        _evaluation?.fechaEvaluacion,
                                        Icons.calendar_today,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateCard(
                                        'Próxima revisión',
                                        _evaluation?.proximaRevision,
                                        Icons.schedule,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.primary,
                                        AppColors.primary.withOpacity(0.8)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppColors.primary.withOpacity(0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EvaluationFormScreen(
                                            animal: widget.animal,
                                            evaluation: _evaluation,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadEvaluation();
                                      }
                                    },
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text(
                                      'Agregar Evaluación',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
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
}
