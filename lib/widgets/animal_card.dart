import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/animal_model.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onDetails;
  final VoidCallback onRescuer;

  const AnimalCard({
    required this.animal,
    required this.onDetails,
    required this.onRescuer,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: animal.imagen != null
                    ? Image.network(
                        'http://localhost:5000/uploads/${animal.imagen}',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 120,
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(Icons.pets, color: Colors.grey),
                          ),
                        ),
                      )
                    : Container(
                        height: 120,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(Icons.pets, color: Colors.grey),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(animal.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(animal.especie ?? 'Especie'),
              Text(animal.raza ?? 'Raza'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onDetails,
                      child: const Text('Datos',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onRescuer,
                      child: const Text('Rescatista',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
