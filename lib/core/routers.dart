import 'package:flutter/material.dart';
import 'package:sistema_animales/screens/animal/animal_form_screen.dart';
import 'package:sistema_animales/screens/animal/animal_list_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
// Agrega más pantallas aquí según crezcas

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String animals = '/animals';
  static const String animalForm = '/animal-form';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => SplashScreen(),
    login: (_) => LoginScreen(),
    register: (_) => RegisterScreen(),
    animals: (_) => AnimalListScreen(),
    animalForm: (_) => const AnimalFormScreen(),
    
  };
}
