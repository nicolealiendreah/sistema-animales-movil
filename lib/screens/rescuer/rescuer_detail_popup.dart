import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/env.dart';
import 'package:sistema_animales/models/rescuer_model.dart';
import 'package:sistema_animales/widgets/modal_card.dart';

class RescuerDetailPopup extends StatelessWidget {
  final Rescuer rescuer;

  RescuerDetailPopup({super.key, required this.rescuer});

  @override
  Widget build(BuildContext context) {
    final raw = rescuer.geolocalizacion?.descripcion;
    final direccion = (raw == null ||
            raw.trim().isEmpty ||
            raw.trim().toLowerCase() == 'ubicación seleccionada')
        ? 'Dirección no disponible'
        : raw.trim();

    return ModalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rescatista',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Información detallada',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: rescuer.imagen != null
                          ? Image.network(
                              '$baseImageUrl/${rescuer.imagen}',
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.grey.shade100,
                                      Colors.grey.shade200,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            )
                          : Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.grey.shade100,
                                    Colors.grey.shade200,
                                  ],
                                ),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                size: 40,
                                color: Colors.grey.shade400,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildModernRow(
                        Icons.person_outline,
                        'Nombre del rescatista:',
                        rescuer.nombre,
                        isFirst: true,
                      ),
                      _buildDivider(),
                      _buildModernRow(
                        Icons.phone_outlined,
                        'Teléfono de contacto:',
                        rescuer.telefono,
                      ),
                      _buildDivider(),
                      _buildModernRow(
                        Icons.calendar_today_outlined,
                        'Fecha del Rescatista:',
                        rescuer.fechaRescatista
                                ?.toIso8601String()
                                .split('T')
                                .first ??
                            'Sin fecha',
                      ),
                      _buildDivider(),
                      _buildModernRow(
                        Icons.location_on_outlined,
                        'Ubicación del Rescatista:',
                        direccion,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernRow(IconData icon, String label, String value,
      {bool isFirst = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            Colors.grey.shade200,
            Colors.transparent,
          ],
        ),
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
