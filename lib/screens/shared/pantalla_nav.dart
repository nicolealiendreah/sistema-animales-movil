import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';

class PantallaNav extends StatelessWidget {
  final BuildContext context;

  const PantallaNav({super.key, required this.context});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.primary,
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.folder_copy_rounded, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.adoptionList);
              },
            ),
            IconButton(
              icon: const Icon(Icons.location_searching, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.liberacionList);
              },
            ),
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.animals);
              },
            ),
            IconButton(
              icon: const Icon(Icons.pets, color: Colors.white),
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
