import 'package:flutter/material.dart';
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

  final TextEditingController nombre = TextEditingController();
  final TextEditingController telefono = TextEditingController();
  final TextEditingController fechaRescate = TextEditingController();
  final TextEditingController ubicacion = TextEditingController();

  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        fechaRescate.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _submit() async {
    if (nombre.text.isEmpty ||
        telefono.text.isEmpty ||
        _selectedDate == null ||
        ubicacion.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    final rescuer = Rescuer(
      nombre: nombre.text,
      telefono: telefono.text,
      fechaRescate: _selectedDate!,
      ubicacionRescate: ubicacion.text,
    );

    try {
      await _rescuerService.create(rescuer);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rescatista registrado exitosamente')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar rescatista: $e')),
      );
    }
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
                    const Text('Rescatista del Animal',
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
                        const Text('Rescatista',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black)),
                        const SizedBox(height: 20),
                        CustomFormTextField(
                            hintText: 'Nombre del rescatista',
                            controller: nombre,
                            icon: Icons.person),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Teléfono de contacto',
                            controller: telefono,
                            icon: Icons.phone),
                        const SizedBox(height: 16),
                        const Text('Fecha del Rescate:',
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomFormTextField(
                              hintText: 'Seleccionar fecha',
                              controller: fechaRescate,
                              icon: Icons.calendar_today,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Ubicación del Rescate',
                            controller: ubicacion,
                            icon: Icons.location_on),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            height: 120,
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black12, blurRadius: 5)
                              ],
                            ),
                            child: const Icon(Icons.image,
                                size: 50, color: Colors.grey),
                          ),
                        ),
                        const SizedBox(height: 28),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('GUARDAR DETALLES RESCATISTA'),
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
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primary,
        shape: const CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.folder_copy_rounded, color: Colors.white),
              Icon(Icons.home, color: Colors.white),
              Icon(Icons.pets, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
