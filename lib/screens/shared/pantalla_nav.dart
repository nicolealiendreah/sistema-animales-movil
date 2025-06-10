import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';

class PantallaNav extends StatelessWidget {
  final BuildContext context;

  const PantallaNav({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.folder_copy_rounded, color: Colors.white),
              tooltip: 'Adopciones',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.adoptionList);
              },
            ),
            IconButton(
              icon: const Icon(Icons.location_searching, color: Colors.white),
              tooltip: 'Liberaciones',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.liberacionList);
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              tooltip: 'Inicio',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.animals);
              },
            ),
            IconButton(
              icon: const Icon(Icons.map, color: Colors.white),
              tooltip: 'Geolocalización',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.geolocation);
              },
            ),
            IconButton(
              icon: const Icon(Icons.pets, color: Colors.white),
              tooltip: 'Reportes',
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.report);
              },
            ),
          ],
        ),
      ),
    );
  }
}
