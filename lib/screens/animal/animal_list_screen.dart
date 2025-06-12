import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';
import 'package:sistema_animales/models/animal_rescatista_model.dart';
import 'package:sistema_animales/screens/animal/animal_detail_popup.dart';
import 'package:sistema_animales/screens/animalhistory/animal_history_screen.dart';
import 'package:sistema_animales/screens/rescuer/rescuer_detail_popup.dart';
import 'package:sistema_animales/screens/shared/pantalla_nav.dart';
import 'package:sistema_animales/servicess/animal_service.dart';
import 'package:sistema_animales/servicess/rescuer_service.dart';
import 'package:sistema_animales/widgets/animal_card.dart';
import 'package:sistema_animales/widgets/loading_indicator.dart';
import 'dart:async';

class AnimalListScreen extends StatefulWidget {
  const AnimalListScreen({super.key});

  @override
  State<AnimalListScreen> createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  final AnimalService _animalService = AnimalService();
  final RescuerService _rescuerService = RescuerService();

  final TextEditingController _searchController = TextEditingController();
  late Future<List<AnimalRescatista>> _futureAnimals;
  List<AnimalRescatista> _allAnimals = [];
  List<AnimalRescatista> _filteredAnimals = [];
  List<AnimalRescatista> _silvestres = [];
  List<AnimalRescatista> _domesticos = [];

  Timer? _timer;

  // Variable para controlar qué categoría mostrar
  String _currentCategory = 'todos'; // 'todos', 'silvestres', 'domesticos'

  @override
  void initState() {
    super.initState();
    _futureAnimals = _loadAnimals();

    _searchController.addListener(() {
      _filterAnimals(_searchController.text);
    });

    _timer = Timer.periodic(const Duration(seconds: 2), (_) async {
      final updatedAnimals = await _animalService.getAll();

      if (!mounted) return;

      setState(() {
        _allAnimals = updatedAnimals;
        _silvestres = updatedAnimals
            .where((a) => a.animal.tipo?.toLowerCase() == 'silvestre')
            .toList();
        _domesticos = updatedAnimals
            .where((a) => a.animal.tipo?.toLowerCase() == 'doméstico')
            .toList();
        _filterAnimals(_searchController.text);
      });
    });
  }

  Future<List<AnimalRescatista>> _loadAnimals() async {
    final animals = await _animalService.getAll();
    setState(() {
      _allAnimals = animals;
      _filteredAnimals = animals;
      _silvestres = animals
          .where((a) => a.animal.tipo?.toLowerCase() == 'silvestre')
          .toList();
      _domesticos = animals
          .where((a) => a.animal.tipo?.toLowerCase() == 'doméstico')
          .toList();
    });
    return animals;
  }

  void _filterAnimals(String query) {
    List<AnimalRescatista> sourceList;

    switch (_currentCategory) {
      case 'silvestres':
        sourceList = _silvestres;
        break;
      case 'domesticos':
        sourceList = _domesticos;
        break;
      default:
        sourceList = _allAnimals;
    }

    final filtered = sourceList.where((item) {
      final name = item.animal.nombre.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredAnimals = filtered;
    });
  }

  void _changeCategory(String category) {
    setState(() {
      _currentCategory = category;
      _filterAnimals(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background2.jpg', fit: BoxFit.cover),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.only(
                    top: 50, left: 20, right: 20, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset('assets/paw_logo.png', height: 45),
                    ),
                    const Text('Lista de Animales',
                        style: AppTextStyles.heading),
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.login,
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                    )
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryButton('Todos', 'todos', Icons.pets),
                    _buildCategoryButton(
                        'Silvestres', 'silvestres', Icons.forest),
                    _buildCategoryButton(
                        'Domésticos', 'domesticos', Icons.home),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar animal...',
                      hintStyle: const TextStyle(color: Colors.black54),
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () => _searchController.clear(),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.95),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<AnimalRescatista>>(
                  future: _futureAnimals,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LoadingIndicator();
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (_filteredAnimals.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No se encontraron animales',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getCurrentCategoryText(),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          mainAxisExtent: 420,
                        ),
                        itemCount: _filteredAnimals.length,
                        itemBuilder: (context, index) {
                          final item = _filteredAnimals[index];

                          return AnimalCard(
                            animal: item.animal,
                            onDetails: () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    AnimalDetailPopup(animal: item.animal),
                              );
                            },
                            onRescuer: () {
                              final rescuer = item.rescuer;
                              if (rescuer != null) {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      RescuerDetailPopup(rescuer: rescuer),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Este animal no tiene rescatista registrado'),
                                  ),
                                );
                              }
                            },
                            onHistory: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AnimalHistoryScreen(
                                      nombre: item.animal.nombre),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'veterinario',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.veterinarioForm),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 5,
            child: const Icon(Icons.medical_services),
            tooltip: 'Registrar Veterinario',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'rescatista',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.rescatistaForm),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 5,
            child: const Icon(Icons.person_add),
            tooltip: 'Registrar Rescatista',
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'animal',
            onPressed: () async {
              final rescatistas = await _rescuerService.getAll();
              if (rescatistas.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Registra al menos un rescatista antes de continuar'),
                  ),
                );
              } else {
                final result =
                    await Navigator.pushNamed(context, AppRoutes.animalForm);
                if (result == true) {
                  final animals = await _animalService.getAll();
                  setState(() {
                    _futureAnimals = Future.value(animals);
                  });
                }
              }
            },
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 5,
            child: const Icon(Icons.add),
            tooltip: 'Registrar Animal',
          ),
        ],
      ),
      bottomNavigationBar: PantallaNav(context: context),
    );
  }

  Widget _buildCategoryButton(String label, String category, IconData icon) {
    final isSelected = _currentCategory == category;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton.icon(
          onPressed: () => _changeCategory(category),
          icon: Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : AppColors.primary,
          ),
          label: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isSelected ? AppColors.primary : Colors.white.withOpacity(0.95),
            foregroundColor: isSelected ? Colors.white : AppColors.primary,
            elevation: isSelected ? 8 : 3,
            shadowColor: Colors.black.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: AppColors.primary,
                width: isSelected ? 0 : 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
      ),
    );
  }

  String _getCurrentCategoryText() {
    switch (_currentCategory) {
      case 'silvestres':
        return 'en la categoría de animales silvestres';
      case 'domesticos':
        return 'en la categoría de animales domésticos';
      default:
        return 'en todas las categorías';
    }
  }
}
