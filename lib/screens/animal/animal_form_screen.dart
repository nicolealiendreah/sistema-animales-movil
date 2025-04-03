import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/widgets/custom_form_text_field.dart';

class AnimalFormScreen extends StatefulWidget {
  const AnimalFormScreen({super.key});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AnimalService();

  final TextEditingController nombre = TextEditingController();
  final TextEditingController especie = TextEditingController();
  final TextEditingController raza = TextEditingController();
  final TextEditingController sexo = TextEditingController();
  final TextEditingController edad = TextEditingController();
  final TextEditingController estadoSalud = TextEditingController();
  final TextEditingController tipoAlimentacion = TextEditingController();
  final TextEditingController cantidadRecomendada = TextEditingController();
  final TextEditingController frecuenciaRecomendada = TextEditingController();
  final TextEditingController fechaLiberacionController = TextEditingController();
  final TextEditingController ubicacionLiberacion = TextEditingController();

  DateTime? _fechaLiberacion;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaLiberacion ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _fechaLiberacion = picked;
        fechaLiberacionController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos obligatorios')),
      );
      return;
    }

    final animal = Animal(
      nombre: nombre.text,
      especie: especie.text,
      raza: raza.text,
      sexo: sexo.text,
      edad: int.tryParse(edad.text),
      estadoSalud: estadoSalud.text,
      tipoAlimentacion: tipoAlimentacion.text,
      cantidadRecomendada: cantidadRecomendada.text,
      frecuenciaRecomendada: frecuenciaRecomendada.text,
      fechaLiberacion: _fechaLiberacion,
      ubicacionLiberacion: ubicacionLiberacion.text,
    );

    final success = await _service.create(animal);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Animal registrado exitosamente')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar animal')),
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
                padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 16),
                color: AppColors.primary,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text('Datos del Animal', style: AppTextStyles.heading),
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
                        const Text('Datos', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Nombre',
                          controller: nombre,
                          icon: Icons.pets,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Especie',
                          controller: especie,
                          icon: Icons.pets,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Raza',
                          controller: raza,
                          icon: Icons.pets,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: CustomFormTextField(
                                hintText: 'Sexo',
                                controller: sexo,
                                icon: Icons.transgender,
                                validator: _requiredValidator,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomFormTextField(
                                hintText: 'Edad',
                                controller: edad,
                                icon: Icons.cake,
                                validator: _requiredValidator,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Estado de Salud',
                          controller: estadoSalud,
                          icon: Icons.health_and_safety,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Tipo de alimentación',
                          controller: tipoAlimentacion,
                          icon: Icons.restaurant,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Cantidad recomendada',
                          controller: cantidadRecomendada,
                          icon: Icons.line_weight,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Frecuencia recomendada',
                          controller: frecuenciaRecomendada,
                          icon: Icons.schedule,
                          validator: _requiredValidator,
                        ),
                        const SizedBox(height: 16),

                        const Text('Fecha de Liberación:', style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 6),

                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomFormTextField(
                              hintText: 'Seleccionar fecha',
                              controller: fechaLiberacionController,
                              icon: Icons.calendar_today,
                              validator: _requiredValidator,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        CustomFormTextField(
                          hintText: 'Ubicación de Liberación',
                          controller: ubicacionLiberacion,
                          icon: Icons.location_on,
                          validator: _requiredValidator,
                        ),

                        const SizedBox(height: 16),
                        const Text('Foto:', style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            height: 100,
                            width: 140,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 5),
                              ],
                            ),
                            child: const Icon(Icons.image, size: 50, color: Colors.grey),
                          ),
                        ),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.buttonText,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('AGREGAR ANIMAL'),
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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }
}