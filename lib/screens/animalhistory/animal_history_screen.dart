import 'package:flutter/material.dart';
import 'package:sistema_animales/servicess/animal_history_service.dart';
import 'package:sistema_animales/core/constants.dart';
import '../../models/animal_historial_model.dart';

class AnimalHistoryScreen extends StatefulWidget {
  final String nombre;

  const AnimalHistoryScreen({Key? key, required this.nombre}) : super(key: key);

  @override
  State<AnimalHistoryScreen> createState() => _AnimalHistoryScreenState();
}

class _AnimalHistoryScreenState extends State<AnimalHistoryScreen> 
    with TickerProviderStateMixin {
  final AnimalHistoryService _historyService = AnimalHistoryService();
  late Future<AnimalHistorial> _futureHistorial;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _futureHistorial = _historyService.getHistorialPorNombre(widget.nombre);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String formatDate(dynamic fecha) {
    try {
      if (fecha == null) return 'No registrada';
      if (fecha is String) {
        final parsed = DateTime.parse(fecha).toLocal();
        return parsed.toString().split(' ')[0];
      }
      if (fecha is DateTime) {
        return fecha.toLocal().toString().split(' ')[0];
      }
      return 'Fecha inválida';
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  Widget _buildModernCard(String title, List<Widget> content, IconData icon, Color iconColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(String title, List<Widget> details, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: color.withOpacity(0.3),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...details,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background2.jpg', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.1),
                ],
              ),
            ),
          ),
          Column(
            children: [
              // Header moderno
              Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historial Médico',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.nombre,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.pets,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Contenido
              Expanded(
                child: FutureBuilder<AnimalHistorial>(
                  future: _futureHistorial,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                'Cargando historial...',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red[300],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error al cargar datos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[400],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: ${snapshot.error}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    } else if (snapshot.data == null) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No se encontraron datos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final historial = snapshot.data!;
                    _animationController.forward();

                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Datos del Animal
                              _buildModernCard(
                                "Información del Animal",
                                [
                                  _buildInfoRow("Nombre", historial.animal.nombre ?? 'No disponible', icon: Icons.pets),
                                  _buildInfoRow("Especie", historial.animal.especie ?? 'No disponible', icon: Icons.category),
                                  _buildInfoRow("Raza", historial.animal.raza ?? 'No disponible', icon: Icons.info_outline),
                                  _buildInfoRow("Sexo", historial.animal.sexo ?? 'No disponible', icon: Icons.wc),
                                  _buildInfoRow("Edad", "${historial.animal.edad?.toString() ?? 'No registrada'} años", icon: Icons.cake),
                                  _buildInfoRow("Estado de salud", historial.animal.estadoSalud ?? 'No disponible', icon: Icons.health_and_safety),
                                  _buildInfoRow("Ubicación rescate", historial.animal.ubicacionRescate ?? 'No disponible', icon: Icons.location_on),
                                ],
                                Icons.pets,
                                AppColors.primary,
                              ),

                              // Rescatista
                              _buildModernCard(
                                "Información del Rescatista",
                                [
                                  _buildInfoRow("Nombre", historial.rescatista.nombre ?? 'No disponible', icon: Icons.person),
                                  _buildInfoRow("Teléfono", historial.rescatista.telefono ?? 'No disponible', icon: Icons.phone),
                                ],
                                Icons.person_pin,
                                Colors.blue,
                              ),

                              // Evaluaciones Médicas
                              _buildModernCard(
                                "Evaluaciones Médicas",
                                historial.evaluations.isEmpty
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.grey),
                                              SizedBox(width: 12),
                                              Text("No se registraron evaluaciones.", 
                                                   style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        )
                                      ]
                                    : historial.evaluations.map((e) => _buildTimelineItem(
                                        "Evaluación - ${formatDate(e.fechaEvaluacion)}",
                                        [
                                          _buildInfoRow("Diagnóstico", e.diagnostico ?? 'No especificado'),
                                          _buildInfoRow("Síntomas", e.sintomas ?? 'No especificado'),
                                          _buildInfoRow("Medicación", e.medicacion ?? 'No especificado'),
                                        ],
                                        Colors.red,
                                      )).toList(),
                                Icons.medical_services,
                                Colors.red,
                              ),

                              // Tratamientos
                              _buildModernCard(
                                "Tratamientos",
                                historial.treatments.isEmpty
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.grey),
                                              SizedBox(width: 12),
                                              Text("No se registraron tratamientos.", 
                                                   style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        )
                                      ]
                                    : historial.treatments.map((t) => _buildTimelineItem(
                                        "Tratamiento",
                                        [
                                          _buildInfoRow("Tratamiento", t.tratamiento ?? 'No especificado'),
                                          _buildInfoRow("Duración", "${t.duracion ?? 'No especificada'} días"),
                                          _buildInfoRow("Observaciones", t.observaciones ?? 'No especificadas'),
                                        ],
                                        Colors.orange,
                                      )).toList(),
                                Icons.healing,
                                Colors.orange,
                              ),

                              // Traslados
                              _buildModernCard(
                                "Traslados",
                                historial.transfers.isEmpty
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.grey),
                                              SizedBox(width: 12),
                                              Text("No se registraron traslados.", 
                                                   style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        )
                                      ]
                                    : historial.transfers.map((t) => _buildTimelineItem(
                                        "Traslado - ${formatDate(t.fechaTraslado)}",
                                        [
                                          _buildInfoRow("Motivo", t.motivo ?? 'No indicado'),
                                          _buildInfoRow("Responsable", t.responsable ?? 'No registrado'),
                                          _buildInfoRow("Observaciones", t.observaciones ?? 'Ninguna'),
                                        ],
                                        Colors.purple,
                                      )).toList(),
                                Icons.transfer_within_a_station,
                                Colors.purple,
                              ),

                              // Liberaciones
                              _buildModernCard(
                                "Liberaciones",
                                historial.liberations.isEmpty
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.grey),
                                              SizedBox(width: 12),
                                              Text("No se registraron liberaciones.", 
                                                   style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        )
                                      ]
                                    : historial.liberations.map((l) => _buildTimelineItem(
                                        "Liberación - ${formatDate(l.fechaLiberacion)}",
                                        [
                                          _buildInfoRow("Observaciones", l.observaciones ?? 'Ninguna'),
                                        ],
                                        Colors.green,
                                      )).toList(),
                                Icons.flight_takeoff,
                                Colors.green,
                              ),

                              // Adopciones
                              _buildModernCard(
                                "Adopciones",
                                historial.adoptions.isEmpty
                                    ? [
                                        Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.info_outline, color: Colors.grey),
                                              SizedBox(width: 12),
                                              Text("Este animal no fue adoptado.", 
                                                   style: TextStyle(color: Colors.grey)),
                                            ],
                                          ),
                                        )
                                      ]
                                    : historial.adoptions.map((a) => _buildTimelineItem(
                                        "Adopción - ${formatDate(a.fechaAdopcion)}",
                                        [
                                          _buildInfoRow("Adoptante", a.nombreAdoptante ?? 'No registrado'),
                                        ],
                                        Colors.pink,
                                      )).toList(),
                                Icons.favorite,
                                Colors.pink,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}