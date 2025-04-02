import 'package:flutter/material.dart';

class ModalCard extends StatelessWidget {
  final Widget child;

  const ModalCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
