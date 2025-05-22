import 'package:flutter/material.dart';
import 'package:sistema_animales/core/constants.dart';
import 'package:sistema_animales/core/routers.dart';
import 'package:sistema_animales/servicess/user_service.dart';
import 'package:sistema_animales/models/user_model.dart';
import 'package:sistema_animales/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final UserService _userService = UserService();

  bool isLoading = false;

  Future<void> _register() async {
    setState(() => isLoading = true);

    final user = User(
      name: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    final success = await _userService.register(user);

    setState(() => isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario registrado correctamente')),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al registrar usuario')),
      );
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
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                              context, AppRoutes.login);
                        },
                      ),
                    ),
                    const Text(
                      'Create una Cuenta',
                      style: AppTextStyles.heading,
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      hintText: 'Primer Nombre',
                      icon: Icons.person_outline,
                      controller: firstNameController,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: 'Apellido',
                      icon: Icons.person_outline,
                      controller: lastNameController,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: 'Usuario',
                      icon: Icons.account_circle_outlined,
                      controller: usernameController,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: 'Contraseña',
                      icon: Icons.lock_outline,
                      controller: passwordController,
                      obscure: true,
                    ),
                    const SizedBox(height: 12),

                    CustomTextField(
                      hintText: 'Correo Electronico',
                      icon: Icons.email_outlined,
                      controller: emailController,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 100, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: isLoading ? null : _register,
                      child: isLoading
                          ? const CircularProgressIndicator()
                          : const Text('REGISTRAR'),
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
