import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/servicess/report_service.dart';
import 'package:sistema_animales/screens/shared/pantalla_nav.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportService _reportService = ReportService();

  Map<String, dynamic> porEspecie = {};
  Map<String, dynamic> porTipo = {};
  Map<String, dynamic> liberacionesPorMes = {};
  Map<String, dynamic> evaluacionesPorAnimal = {};
  Map<String, dynamic> trasladosPorAnimal = {};

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    try {
      porEspecie = await _reportService.getBySpecies();
      porTipo = await _reportService.getByType();
      liberacionesPorMes = await _reportService.getLiberationsPerMonth();
      evaluacionesPorAnimal = await _reportService.getEvaluationsPerAnimal();
      trasladosPorAnimal = await _reportService.getTransfersPerAnimal();
    } catch (e) {
      print('Error al cargar reportes: $e');
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildChartCard(String title, Map<String, dynamic> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    final total = entries.fold<int>(0, (sum, e) => sum + (e.value as int));

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          data.isEmpty
              ? const Text('Sin datos disponibles',
                  style: TextStyle(color: Colors.grey))
              : SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: entries.map((e) {
                        final percent =
                            total == 0 ? 0 : (e.value / total) * 100;
                        return PieChartSectionData(
                          title: percent < 1
                              ? ''
                              : '${e.key}\n${percent.toStringAsFixed(1)}%',
                          value: (e.value as num).toDouble(),
                          radius: 70,
                          titleStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                          color: Colors.primaries[
                                  entries.indexOf(e) % Colors.primaries.length]
                              .withOpacity(0.9),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard(String title, Map<String, dynamic> data) {
    final entries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)); // orden cronológico

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                barGroups: entries.asMap().entries.map((entry) {
                  final i = entry.key;
                  final e = entry.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: (e.value as num).toDouble(),
                        width: 16,
                        color: Colors.blueAccent,
                      ),
                    ],
                    showingTooltipIndicators: [0],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index >= 0 && index < entries.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              entries[index].key.substring(5), // MM
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
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
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 16),
                color: AppColors.primary,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text('Reportes Automáticos',
                        style: AppTextStyles.heading),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildChartCard('Cantidad por especie', porEspecie),
                            _buildChartCard(
                                'Cantidad por tipo de animal', porTipo),
                            _buildBarChartCard(
                                'Liberaciones por mes', liberacionesPorMes),
                            _buildChartCard('Evaluaciones por animal',
                                evaluacionesPorAnimal),
                            _buildChartCard(
                                'Traslados por animal', trasladosPorAnimal),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: PantallaNav(context: context),
    );
  }
}
