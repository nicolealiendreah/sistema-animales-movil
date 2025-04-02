import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../widgets/modal_card.dart';

class RescuerDetailPopup extends StatelessWidget {
  const RescuerDetailPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: const [
              Icon(Icons.arrow_back),
              SizedBox(width: 8),
              Text('Rescatista Animal 1', style: AppTextStyles.heading),
            ],
          ),
          const SizedBox(height: 16),

          // Datos
          _buildRow('Nombre del rescatista:', 'Juan Pérez'),
          _buildRow('Teléfono de contacto:', '+591 78912345'),
          _buildRow('Fecha del Rescate:', '2024-04-01'),
          _buildRow('Ubicación del Rescate:', 'Av. Siempre Viva 123'),

          const SizedBox(height: 16),

          // Imagen
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

          // Botones de navegación
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _actionButton(Icons.pets, 'Ev.Medicas'),
              _actionButton(Icons.location_on, 'Geolocalizacion'),
              _actionButton(Icons.list_alt, 'Historial Traslados'),
            ],
          ),
          const SizedBox(height: 16),

          // Botón de editar
          Align(
            alignment: Alignment.center,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              onPressed: () {
                // Acción para agregar o editar
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
          Expanded(flex: 4, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary.withOpacity(0.9),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {},
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
