import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/servicess/rescuer_service.dart';
import 'package:sistema_animales/widgets/custom_form_text_field.dart';

class RescuerFormScreen extends StatefulWidget {
  const RescuerFormScreen({super.key});

  @override
  State<RescuerFormScreen> createState() => _RescuerFormScreenState();
}

class _RescuerFormScreenState extends State<RescuerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _rescuerService = RescuerService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  DateTime? _fechaRescate;

  Future<void> _selectFechaRescate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaRescate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaRescate = picked;
        _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _guardarRescatista() async {
    if (_formKey.currentState!.validate() && _fechaRescate != null) {
      final nuevo = Rescuer(
        nombre: _nombreController.text,
        telefono: _telefonoController.text,
        fechaRescate: _fechaRescate!,
        ubicacionRescate: _ubicacionController.text,
      );

      await _rescuerService.create(nuevo);
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
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
                    const Text('Registrar Rescatista',
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Datos del Rescatista',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          hintText: 'Nombre',
                          controller: _nombreController,
                          icon: Icons.person,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          hintText: 'Teléfono',
                          controller: _telefonoController,
                          icon: Icons.phone,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectFechaRescate(context),
                          child: AbsorbPointer(
                            child: CustomFormTextField(
                              hintText: 'Seleccionar fecha de Nacimiento',
                              controller: _fechaController,
                              icon: Icons.calendar_today,
                              validator: _requiredValidator,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                          hintText: 'Ubicación de vivienda del Rescatista',
                          controller: _ubicacionController,
                          icon: Icons.location_on,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _guardarRescatista,
                          label: const Text('Guardar Detalles Rescatista'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                        const SizedBox(height: 60),
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
}
