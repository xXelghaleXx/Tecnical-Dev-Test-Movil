import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final response = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        if (response.success) {
          // Cargar productos después del login exitoso
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
                loadingMessage: 'Iniciando sesión...',
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingL),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.paddingXL),
                      _buildHeader(),
                      const SizedBox(height: AppSizes.paddingXL * 2),
                      _buildLoginForm(),
                      const SizedBox(height: AppSizes.paddingL),
                      _buildRegisterLink(),
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
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppSizes.radiusXL),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSizes.paddingM),
        Text(
          AppStrings.appName,
          style: AppTextStyles.heading1.copyWith(
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSizes.paddingS),
        Text(
          'Inicia sesión en tu cuenta',
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
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
              hint: 'Tu contraseña',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline,
              validator: _validatePassword,
            ),
            const SizedBox(height: AppSizes.paddingL),
            CustomButton(
              text: AppStrings.login,
              onPressed: _login,
              icon: Icons.login,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: Column(
        children: [
          Text(
            '¿No tienes una cuenta?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: AppSizes.paddingS),
          CustomButton(
            text: AppStrings.register,
            onPressed: () {
              Navigator.of(context).pushNamed('/register');
            },
            isOutlined: true,
            backgroundColor: Colors.white,
            textColor: Colors.white,
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }
}