import 'package:flutter/material.dart';
import 'package:sistema_animales/core/env.dart';
import 'package:sistema_animales/screens/evaluation/medical_evaluation_screen.dart';
import 'package:sistema_animales/screens/geolocation/geolocation_screen.dart';
import 'package:sistema_animales/screens/transfer/transfer_list_screen.dart';
import 'package:sistema_animales/screens/treatment/treatment_screen.dart';
import '../../../models/animal_model.dart';
import '../../../core/constants.dart';
import '../../../widgets/modal_card.dart';

class AnimalDetailPopup extends StatelessWidget {
  final Animal animal;

  const AnimalDetailPopup({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 8),
              Text(
                'Datos ${animal.nombre}',
                style: AppTextStyles.heading.copyWith(color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRow('Nombre:', animal.nombre),
          _buildRow('Especie:', animal.especie ?? ''),
          _buildRow('Raza:', animal.raza ?? ''),
          _buildRow('Sexo:', animal.sexo ?? ''),
          _buildRow('Edad:', animal.edad?.toString() ?? ''),
          _buildRow('Estado de Salud:', animal.estadoSalud ?? ''),
          _buildRow('Tipo:', animal.tipo ?? ''),
          _buildRow('Tipo de alimentación:', animal.tipoAlimentacion ?? ''),
          _buildRow('Cantidad recomendada:', animal.cantidadRecomendada ?? ''),
          _buildRow(
              'Frecuencia recomendada:', animal.frecuenciaRecomendada ?? ''),
          _buildRow(
            'Fecha del Rescate:',
            animal.fechaRescate != null
                ? animal.fechaRescate!.toIso8601String().split('T').first
                : 'Sin fecha',
          ),
          _buildRow('Ubicación del rescate:', animal.ubicacionRescate ?? ''),
          _buildRow('Detalles del rescate:', animal.detallesRescate ?? ''),
          const SizedBox(height: 16),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: animal.imagen != null
                  ? Image.network(
                      '$baseImageUrl/${animal.imagen}',
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        width: 150,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported,
                            size: 40, color: Colors.grey),
                      ),
                    )
                  : Container(
                      height: 120,
                      width: 120,
                      color: Colors.grey.shade200,
                      child:
                          const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MedicalEvaluationScreen(animal: animal),
                    ),
                  );
                },
                icon: const Icon(Icons.pets, size: 18),
                label: const Text('Ev.Medicas'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TreatmentDetailScreen(animal: animal),
                    ),
                  );
                },
                icon: const Icon(Icons.pets, size: 18),
                label: const Text('Tratamientos'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GeolocationScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.location_on, size: 18),
                label: const Text('Geolocalizacion'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TransferListScreen(animal: animal),
                    ),
                  );
                },
                icon: const Icon(Icons.list_alt, size: 18),
                label: const Text('Historial Traslados'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }
}
