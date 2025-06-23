import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final response = await authProvider.register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (response.success) {
          // Cargar productos después del registro exitoso
          await productProvider.loadProducts();
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          _showErrorSnackBar(response.message);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
    );
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es requerido';
    }
    if (value.length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }
    if (value.length > 20) {
      return 'El nombre de usuario no puede tener más de 20 caracteres';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Solo se permiten letras, números y guiones bajos';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d)').hasMatch(value)) {
      return 'La contraseña debe contener al menos una letra y un número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: SafeArea(
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return LoadingOverlay(
                isLoading: authProvider.isLoading,
                loadingMessage: 'Creando cuenta...',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.paddingL),
                      _buildHeader(),
                      const SizedBox(height: AppSizes.paddingXL),
                      _buildRegisterForm(),
                      const SizedBox(height: AppSizes.paddingL),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusL),
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          'Crear Cuenta',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          'Únete a ${AppStrings.appName}',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            CustomTextField(
              label: AppStrings.username,
              hint: 'usuario123',
              controller: _usernameController,
              prefixIcon: Icons.person_outline,
              validator: _validateUsername,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomTextField(
              label: AppStrings.email,
              hint: 'tu@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: _validateEmail,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomTextField(
              label: AppStrings.password,
              hint: 'Mínimo 6 caracteres',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: _validatePassword,
            ),
            const SizedBox(height: AppSizes.paddingM),
            CustomTextField(
              label: AppStrings.confirmPassword,
              hint: 'Repite tu contraseña',
              controller: _confirmPasswordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: _validateConfirmPassword,
            ),
            const SizedBox(height: AppSizes.paddingL),
            CustomButton(
              text: AppStrings.register,
              onPressed: _register,
              icon: Icons.person_add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          Text(
            '¿Ya tienes una cuenta?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          CustomButton(
            text: AppStrings.login,
            onPressed: () {
              Navigator.of(context).pop();
            },
            isOutlined: true,
            backgroundColor: Colors.white,
            textColor: Colors.white,
            icon: Icons.login,
          ),
        ],
      ),
    );
  }
}