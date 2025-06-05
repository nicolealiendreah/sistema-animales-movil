import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/env.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/widgets/modal_card.dart';

class RescuerDetailPopup extends StatelessWidget {
  final Rescuer rescuer;
  
  const RescuerDetailPopup({super.key, required this.rescuer});

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              const Text(
                'Rescatista',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildRow('Nombre del rescatista:', rescuer.nombre),
          _buildRow('Teléfono de contacto:', rescuer.telefono),
          _buildRow(
              'Fecha del Rescatista:',
              rescuer.fechaRescatista != null
                  ? rescuer.fechaRescatista!.toIso8601String().split('T').first
                  : 'Sin fecha'),
          _buildRow('Ubicación del Rescatista:',
              rescuer.geolocalizacion?.descripcion ?? 'Ubicacion Seleccionada'),
          const SizedBox(height: 16),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: rescuer.imagen != null
                  ? Image.network(
                      '$baseImageUrl/${rescuer.imagen}',
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
                      height: 150,
                      width: 150,
                      color: Colors.grey.shade200,
                      child:
                          const Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
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

  Widget _actionButton(IconData icon, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
