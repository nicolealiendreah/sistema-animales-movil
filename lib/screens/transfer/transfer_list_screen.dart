import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/models/animal_model.dart';
import 'package:sistema_animales/models/transfer_model.dart';
import 'package:sistema_animales/servicess/transfer_service.dart';
import 'transfer_form_screen.dart';

class TransferListScreen extends StatefulWidget {
  final Animal animal;

  const TransferListScreen({super.key, required this.animal});

  @override
  State<TransferListScreen> createState() => _TransferListScreenState();
}

class _TransferListScreenState extends State<TransferListScreen>
    with SingleTickerProviderStateMixin {
  final TransferService _transferService = TransferService();
  bool _isLoading = true;
  String? _error;
  List<Transfer> _transfers = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadTransfer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTransfer() async {
    try {
      final transfers = await _transferService.getAll();
      final matching = transfers
          .where((t) => t.nombreAnimal == widget.animal.nombre)
          .toList();

      setState(() {
        _transfers = matching;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime? date) =>
      date != null ? DateFormat.yMMMd().format(date) : '-';

  String _formatTime(DateTime? date) =>
      date != null ? DateFormat.jm().format(date) : '-';

  Widget _buildInfoChip(String label, String? value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(DateTime? date) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fecha de traslado',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                _formatDate(date),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                _formatTime(date),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUbicacionNuevaText(Transfer t) {
    return 'Ubicación seleccionada';
  }

  String _getUbicacionAnteriorText(Transfer t) {
    return 'Ubicación seleccionada';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Historial de Traslados',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'y Seguimiento',
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando traslados...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.red.shade600, size: 48),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Error al cargar los datos',
                                    style: TextStyle(
                                      color: Colors.red.shade800,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    style: TextStyle(
                                      color: Colors.red.shade600,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : FadeTransition(
                            opacity: _fadeAnimation,
                            child: CustomScrollView(
                              slivers: [
                                SliverPadding(
                                  padding: const EdgeInsets.all(20),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        if (index < _transfers.length) {
                                          final t = _transfers[index];
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 24),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withOpacity(0.05),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(20),
                                                      topRight:
                                                          Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppColors.primary,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: const Icon(
                                                          Icons
                                                              .transfer_within_a_station,
                                                          color: Colors.white,
                                                          size: 20,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Traslado ${index + 1}',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      _buildInfoChip(
                                                          'Ubicación anterior',
                                                          _getUbicacionAnteriorText(
                                                              t)),
                                                      _buildInfoChip(
                                                          'Ubicación nueva',
                                                          _getUbicacionNuevaText(
                                                              t)),
                                                      _buildInfoChip(
                                                          'Motivo del traslado',
                                                          t.motivo),
                                                      _buildInfoChip(
                                                          'Observaciones',
                                                          t.observaciones),
                                                      _buildInfoChip(
                                                          'Responsable',
                                                          t.responsable),
                                                      const SizedBox(
                                                          height: 16),
                                                      _buildDateTimeCard(
                                                          t.fechaTraslado),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 20),
                                            child: Center(
                                              child: Container(
                                                width: double.infinity,
                                                child: ElevatedButton.icon(
                                                  onPressed: () async {
                                                    final result =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            TransferFormScreen(
                                                                animal: widget
                                                                    .animal),
                                                      ),
                                                    );

                                                    if (result == true) {
                                                      _loadTransfer();
                                                    }
                                                  },
                                                  icon: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                    ),
                                                    child: const Icon(Icons.add,
                                                        size: 18),
                                                  ),
                                                  label: const Text(
                                                    'Agregar Nuevo Traslado',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        AppColors.primary,
                                                    foregroundColor:
                                                        Colors.white,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 18),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    elevation: 4,
                                                    shadowColor: AppColors
                                                        .primary
                                                        .withOpacity(0.3),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      childCount: _transfers.length + 1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
