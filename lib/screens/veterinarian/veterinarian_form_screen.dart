import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/veterinarian_model.dart';
import 'package:sistema_animales/servicess/veterinario_service.dart';
import 'package:sistema_animales/widgets/custom_form_text_field.dart';

class VeterinarioFormScreen extends StatefulWidget {
  const VeterinarioFormScreen({super.key});

  @override
  State<VeterinarioFormScreen> createState() => _VeterinarioFormScreenState();
}

class _VeterinarioFormScreenState extends State<VeterinarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = VeterinarioService();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _guardarVeterinario() async {
    if (_formKey.currentState!.validate()) {
      final nuevo = Veterinario(
        nombre: _nombreController.text,
        especialidad: _especialidadController.text,
        telefono: _telefonoController.text,
        email: _emailController.text,
        
      );

      await _service.create(nuevo);
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
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 16),
                color: AppColors.primary,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text('Registrar Veterinario', style: AppTextStyles.heading),
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
                        const Text('Datos del Veterinario',
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
                          hintText: 'Especialidad',
                          controller: _especialidadController,
                          icon: Icons.local_hospital,
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
                        CustomFormTextField(
                          hintText: 'Email',
                          controller: _emailController,
                          icon: Icons.email,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _guardarVeterinario,
                          label: const Text('Guardar Detalles Veterinario'),
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
