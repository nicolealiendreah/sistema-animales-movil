import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/screens/animal/animal_detail_popup.dart';
import 'package:sistema_animales/screens/rescuer/rescuer_detail_popup.dart';
import 'package:sistema_animales/widgets/animal_card.dart';

class AnimalListScreen extends StatelessWidget {
  const AnimalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación de animales
    final List<Animal> animals = [
      Animal(nombre: 'Animal 1', especie: 'Perro', raza: 'Labrador'),
      Animal(nombre: 'Animal 2', especie: 'Gato', raza: 'Siames'),
      Animal(nombre: 'Animal 3', especie: 'Conejo', raza: 'Enano'),
      Animal(nombre: 'Animal 4', especie: 'Tortuga', raza: 'Galápagos'),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text('Lista de Animales', style: AppTextStyles.heading),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7, // ✅ ajustado para evitar overflow
                  ),
                  itemCount: animals.length,
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    return AnimalCard(
                      animal: animal,
                      onDetails: () {
                        showDialog(
                          context: context,
                          builder: (_) => AnimalDetailPopup(animal: animal),
                        );
                      },
                      onRescuer: () {
                        showDialog(
                          context: context,
                          builder: (_) => const RescuerDetailPopup(),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Acción para ir a agregar animal
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
