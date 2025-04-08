import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

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
              icon: const Icon(Icons.folder_copy_rounded),
              color: selectedIndex == 0 ? Colors.yellow : Colors.white,
              onPressed: () => onItemTapped(0),
            ),
            IconButton(
              icon: const Icon(Icons.home),
              color: selectedIndex == 1 ? Colors.yellow : Colors.white,
              onPressed: () => onItemTapped(1),
            ),
            IconButton(
              icon: const Icon(Icons.pets),
              color: selectedIndex == 2 ? Colors.yellow : Colors.white,
              onPressed: () => onItemTapped(2),
            ),
          ],
        ),
      ),
    );
  }
}
