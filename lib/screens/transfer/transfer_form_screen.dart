import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/transfer_model.dart';
import 'package:sistema_animales/servicess/transfer_service.dart';

class TransferFormScreen extends StatefulWidget {
  final Animal animal;

  const TransferFormScreen({super.key, required this.animal});

  @override
  State<TransferFormScreen> createState() => _TransferFormScreenState();
}

class _TransferFormScreenState extends State<TransferFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = TransferService();

  final TextEditingController _ubicacionAnterior = TextEditingController();
  final TextEditingController _ubicacionNueva = TextEditingController();
  final TextEditingController _motivo = TextEditingController();
  final TextEditingController _responsable = TextEditingController();
  final TextEditingController _observaciones = TextEditingController();

  DateTime? _fechaTraslado;

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
      _fechaTraslado =
          DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final transfer = Transfer(
      nombreAnimal: widget.animal.nombre,
      ubicacionAnterior: _ubicacionAnterior.text,
      ubicacionNueva: _ubicacionNueva.text,
      motivo: _motivo.text,
      observaciones: _observaciones.text,
      responsable: _responsable.text,
      fechaTraslado: _fechaTraslado ?? DateTime.now(),
    );

    print('🔼 Enviando Transfer: ${transfer.toJson()}');

    try {
      await _service.create(transfer);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Traslado registrado')),
      );
      Navigator.pop(context, true); // 👈 para refrescar
    } catch (e) {
      if (!mounted) return;
      print('❌ Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
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
                        'Historial de Traslados y Seguimiento',
                        style: AppTextStyles.heading.copyWith(fontSize: 18),
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
                        _buildField('Ubicación Anterior', _ubicacionAnterior),
                        _buildField('Ubicación Nueva', _ubicacionNueva),
                        _buildField('Motivo Traslado', _motivo),
                        _buildField('Responsable del Traslado', _responsable),
                        _buildField('Observaciones', _observaciones),
                        const SizedBox(height: 16),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Fecha de Traslado:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: _pickDateTime,
                              child: Text(_formatDate(_fechaTraslado),
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                            TextButton(
                              onPressed: _pickDateTime,
                              child: Text(_formatTime(_fechaTraslado),
                                  style: const TextStyle(color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 100, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('GUARDAR'),
                        ),
                        const SizedBox(height: 32),
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

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
