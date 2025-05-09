import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/tratamiento_model.dart';
import 'package:sistema_animales/servicess/tratamiento_service.dart';

import 'treatment_form_screen.dart';

class TreatmentDetailScreen extends StatefulWidget {
  final Animal animal;

  const TreatmentDetailScreen({super.key, required this.animal});

  @override
  State<TreatmentDetailScreen> createState() => _TreatmentDetailScreenState();
}

class _TreatmentDetailScreenState extends State<TreatmentDetailScreen> {
  final TratamientoService _treatmentService = TratamientoService();
  Tratamiento? _treatment;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTreatment();
  }

  Future<void> _loadTreatment() async {
    try {
      final treatments = await _treatmentService.getAll();
      final matching = treatments.firstWhere(
        (t) => t.nombreAnimal == widget.animal.nombre,
        orElse: () => Tratamiento(
          nombreAnimal: widget.animal.nombre,
          tratamiento: '',
          fechaTratamiento: null,
          responsable: '',
          observaciones: '',
          duracion: '',
        ),
      );

      setState(() {
        _treatment = matching;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

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
                        'Tratamiento del Animal',
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
                      color: Colors.black,
                    ),
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
                                      _buildRow('Tratamiento:',
                                          _treatment?.tratamiento),
                                      _buildRow(
                                          'Duración:', _treatment?.duracion),
                                      _buildRow('Responsable:',
                                          _treatment?.responsable),
                                      _buildRow('Observaciones:',
                                          _treatment?.observaciones),
                                      const SizedBox(height: 12),
                                      const Text('Fecha de Tratamiento:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                        _formatDate(
                                            _treatment?.fechaTratamiento),
                                        style:
                                            const TextStyle(color: Colors.blue),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TreatmentFormScreen(
                                            animal: widget.animal),
                                      ),
                                    );
                                    if (result == true) {
                                      _loadTreatment();
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar Tratamiento'),
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
