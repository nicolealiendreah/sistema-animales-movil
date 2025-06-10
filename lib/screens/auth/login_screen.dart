import 'package:flutter/material.dart';
import 'package:sistema_animales/core/routers.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/servicess/user_service.dart';
import 'package:sistema_animales/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool isLoading = false;

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, completa todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await _userService.login(email, password);

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, AppRoutes.animals);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Credenciales incorrectas')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background.jpg', fit: BoxFit.cover),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset('assets/paw_logo.png',
                            fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      hintText: 'Correo electrónico',
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      hintText: 'Contraseña',
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('INICIAR SESIÓN'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.register);
                      },
                      child: const Text(
                        'Crear una cuenta',
                        style: TextStyle(color: AppColors.textDark),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Image.asset('assets/vet_with_dog.png', height: 180),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
