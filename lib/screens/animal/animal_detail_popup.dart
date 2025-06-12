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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Text(
                'Datos de ${animal.nombre}',
                style: AppTextStyles.heading.copyWith(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Información Básica', Icons.info_outline),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow('Nombre', animal.nombre, Icons.badge),
                    _buildInfoRow('Especie',
                        animal.especie ?? 'No especificado', Icons.category),
                    _buildInfoRow(
                        'Raza', animal.raza ?? 'No especificado', Icons.pets),
                    _buildInfoRow(
                        'Sexo', animal.sexo ?? 'No especificado', Icons.wc),
                    _buildInfoRow(
                        'Edad',
                        animal.edad?.toString() ?? 'No especificado',
                        Icons.calendar_today),
                    _buildInfoRow(
                        'Estado de Salud',
                        animal.estadoSalud ?? 'No especificado',
                        Icons.health_and_safety),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                      'Cuidado y Alimentación', Icons.restaurant),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow('Tipo', animal.tipo ?? 'No especificado',
                        Icons.type_specimen),
                    _buildInfoRow(
                        'Tipo de alimentación',
                        animal.tipoAlimentacion ?? 'No especificado',
                        Icons.dining),
                    _buildInfoRow(
                        'Cantidad recomendada',
                        animal.cantidadRecomendada ?? 'No especificado',
                        Icons.straighten),
                    _buildInfoRow(
                        'Frecuencia recomendada',
                        animal.frecuenciaRecomendada ?? 'No especificado',
                        Icons.schedule),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                      'Información de Rescate', Icons.location_on),
                  const SizedBox(height: 12),
                  _buildInfoCard([
                    _buildInfoRow(
                        'Fecha del Rescate',
                        animal.fechaRescate != null
                            ? animal.fechaRescate!
                                .toIso8601String()
                                .split('T')
                                .first
                            : 'Sin fecha',
                        Icons.event),
                    _buildInfoRow(
                      'Ubicación del rescate',
                      animal.geolocalizacion?.descripcion ??
                          animal.ubicacionRescate ??
                          'No especificado',
                      Icons.place,
                    ),
                    _buildInfoRow(
                        'Detalles del rescate',
                        animal.detallesRescate ?? 'No especificado',
                        Icons.description),
                  ]),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Imagen', Icons.photo),
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: animal.imagen != null
                            ? Image.network(
                                '$baseImageUrl/${animal.imagen}',
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey.shade100,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image_not_supported,
                                          size: 48,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Error al cargar imagen',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(
                                height: 200,
                                width: double.infinity,
                                color: Colors.grey.shade100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image,
                                        size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Sin imagen disponible',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                          icon: const Icon(Icons.medical_services, size: 20),
                          label: const Text(
                            'Evaluaciones Médicas',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
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
                          icon: const Icon(Icons.healing, size: 20),
                          label: const Text(
                            'Tratamientos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TransferListScreen(animal: animal),
                              ),
                            );
                          },
                          icon: const Icon(Icons.transfer_within_a_station,
                              size: 20),
                          label: const Text(
                            'Historial de Traslados',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
