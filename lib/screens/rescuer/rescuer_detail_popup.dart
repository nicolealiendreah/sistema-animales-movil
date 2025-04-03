import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/screens/rescuer/rescuer_form_screen.dart';
import 'package:sistema_animales/servicess/rescuer_service.dart';
import 'package:sistema_animales/widgets/modal_card.dart';
import 'package:intl/intl.dart';

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
            children: const [
              Icon(Icons.arrow_back),
              SizedBox(width: 8),
              Text(
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
              'Fecha del Rescate:',
              rescuer.fechaRescate != null
                  ? rescuer.fechaRescate!.toString().split('T').first
                  : 'Sin fecha'),
          _buildRow('Ubicación del Rescate:', rescuer.ubicacionRescate),
          const SizedBox(height: 16),
          Center(
            child: Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.image, size: 40, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
        
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RescuerFormScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar/Editar Datos'),
            ),
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
