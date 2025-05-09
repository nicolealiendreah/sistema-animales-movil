import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/servicess/rescuer_service.dart';
import 'package:sistema_animales/widgets/custom_form_text_field.dart';
import 'package:intl/intl.dart';

class AnimalFormScreen extends StatefulWidget {
  const AnimalFormScreen({super.key});

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AnimalService();
  final _rescuerService = RescuerService();

  final TextEditingController nombre = TextEditingController();
  final TextEditingController especie = TextEditingController();
  final TextEditingController raza = TextEditingController();
  final TextEditingController edad = TextEditingController();
  final TextEditingController estadoSalud = TextEditingController();
  final TextEditingController tipoAlimentacion = TextEditingController();
  final TextEditingController cantidadRecomendada = TextEditingController();
  final TextEditingController frecuenciaRecomendada = TextEditingController();
  final TextEditingController fechaLiberacionController =
      TextEditingController();
  final TextEditingController ubicacionLiberacion = TextEditingController();

  DateTime? _fechaLiberacion;
  String? selectedTipo;
  String? selectedSexo;
  String? selectedRescatista;
  String? selectedTelefono;
  List<Rescuer> rescatistas = [];
  DateTime? selectedFechaRescate;
  String? selectedUbicacionRescate;

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
        fechaLiberacionController.text =
            DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _loadRescatistas() async {
    final lista = await _rescuerService.getAll();
    setState(() {
      rescatistas = lista;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRescatistas();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, complete todos los campos obligatorios')),
      );
      return;
    }

    final selectedRescuer =
        rescatistas.firstWhere((r) => r.nombre == selectedRescatista);

    final data = {
      "nombre": nombre.text,
      "especie": especie.text,
      "raza": raza.text,
      "sexo": selectedSexo,
      "edad": int.tryParse(edad.text),
      "estadoSalud": estadoSalud.text,
      "tipo": selectedTipo,
      "tipoAlimentacion": tipoAlimentacion.text,
      "cantidadRecomendada": cantidadRecomendada.text,
      "frecuenciaRecomendada": frecuenciaRecomendada.text,
      "fechaLiberacion": _fechaLiberacion?.toIso8601String(),
      "ubicacionLiberacion": ubicacionLiberacion.text,
      "nombreRescatista": selectedRescuer.nombre,
      "telefonoRescatista": selectedTelefono,
    };

    final success = await _service.create(data);

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
                    const Text('Datos del Animal',
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
                        const Text('Datos',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Nombre',
                            controller: nombre,
                            icon: Icons.pets,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Especie',
                            controller: especie,
                            icon: Icons.pets,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Raza',
                            controller: raza,
                            icon: Icons.pets,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedSexo,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.transgender),
                              labelText: 'Sexo'),
                          items: ['Macho', 'Hembra']
                              .map((sexo) => DropdownMenuItem(
                                  value: sexo, child: Text(sexo)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedSexo = value),
                          validator: (value) =>
                              value == null ? 'Seleccione un sexo' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Edad',
                            controller: edad,
                            icon: Icons.cake,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Estado de Salud',
                            controller: estadoSalud,
                            icon: Icons.health_and_safety,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedTipo,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.category),
                              labelText: 'Tipo del Animal'),
                          items: ['Silvestre', 'Doméstico']
                              .map((tipo) => DropdownMenuItem(
                                  value: tipo, child: Text(tipo)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedTipo = value),
                          validator: (value) =>
                              value == null ? 'Seleccione un tipo' : null,
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Tipo de alimentación',
                            controller: tipoAlimentacion,
                            icon: Icons.restaurant,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Cantidad recomendada',
                            controller: cantidadRecomendada,
                            icon: Icons.line_weight,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Frecuencia recomendada',
                            controller: frecuenciaRecomendada,
                            icon: Icons.schedule,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomFormTextField(
                              hintText: 'Seleccionar fecha de rescate',
                              controller: fechaLiberacionController,
                              icon: Icons.calendar_today,
                              validator: _requiredValidator,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CustomFormTextField(
                            hintText: 'Ubicación de rescate',
                            controller: ubicacionLiberacion,
                            icon: Icons.location_on,
                            validator: _requiredValidator),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedRescatista,
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              labelText: 'Nombre del Rescatista'),
                          items: rescatistas
                              .map((r) => DropdownMenuItem(
                                  value: r.nombre, child: Text(r.nombre)))
                              .toList(),
                          onChanged: (value) {
                            final resc = rescatistas
                                .firstWhere((r) => r.nombre == value);
                            setState(() {
                              selectedRescatista = value;
                              selectedTelefono = resc.telefono;
                              selectedFechaRescate = resc.fechaRescate;
                              selectedUbicacionRescate = resc.ubicacionRescate;
                            });
                          },
                          validator: (value) =>
                              value == null ? 'Seleccione un rescatista' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: selectedTelefono,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.phone),
                            labelText: 'Teléfono del Rescatista',
                          ),
                          items: rescatistas
                              .map((r) => DropdownMenuItem(
                                  value: r.telefono, child: Text(r.telefono)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => selectedTelefono = value),
                          validator: (value) =>
                              value == null ? 'Seleccione un teléfono' : null,
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
    );
  }
}
