import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../models/animal_model.dart';

class AnimalCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback? onDetails;
  final VoidCallback? onRescuer;

  const AnimalCard({
    super.key,
    required this.animal,
    this.onDetails,
    this.onRescuer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Imagen (espacio en blanco por ahora)
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.image, color: Colors.grey)),
            ),
            const SizedBox(height: 8),

            // Info
            Text(animal.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(animal.especie ?? 'Especie'),
            Text(animal.raza ?? 'Raza'),
            const SizedBox(height: 8),

            // Botones
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
                    child: const Text(
                      'Datos',
                      style: TextStyle(color: Colors.white),
                    ),  
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
                    child: const Text(
                      'Rescatista',
                      style: TextStyle(color: Colors.white),
                    ),

                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
