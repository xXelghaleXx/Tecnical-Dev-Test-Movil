import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../models/product.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  Product? _editingProduct;
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verificar si se pasó un producto para editar
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Product && _editingProduct == null) {
      _editingProduct = args;
      _isEditMode = true;
      _populateFields();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _populateFields() {
    if (_editingProduct != null) {
      _nameController.text = _editingProduct!.name;
      _descriptionController.text = _editingProduct!.description;
      _priceController.text = _editingProduct!.price.toString();
      _stockController.text = _editingProduct!.stock.toString();
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    if (authProvider.token == null) {
      _showErrorSnackBar('Error de autenticación');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.parse(_priceController.text);
      final stock = int.parse(_stockController.text);

      late final response;

      if (_isEditMode && _editingProduct != null) {
        // Actualizar producto existente
        response = await productProvider.updateProduct(
          productId: _editingProduct!.id,
          name: name,
          description: description,
          price: price,
          stock: stock,
          token: authProvider.token!,
        );
      } else {
        // Crear nuevo producto
        response = await productProvider.createProduct(
          name: name,
          description: description,
          price: price,
          stock: stock,
          token: authProvider.token!,
        );
      }

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (response.success) {
          _showSuccessSnackBar(response.message);
          Navigator.of(context).pop();
        } else {
          _showErrorSnackBar(response.message);
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error al procesar los datos: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: AppSizes.paddingS),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusS),
        ),
      ),
    );
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

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre del producto es requerido';
    }
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    if (value.trim().length > 100) {
      return 'El nombre no puede tener más de 100 caracteres';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La descripción es requerida';
    }
    if (value.trim().length < 5) {
      return 'La descripción debe tener al menos 5 caracteres';
    }
    if (value.trim().length > 500) {
      return 'La descripción no puede tener más de 500 caracteres';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es requerido';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Ingresa un precio válido';
    }
    if (price <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    if (price > 999999.99) {
      return 'El precio no puede ser mayor a \$999,999.99';
    }
    return null;
  }

  String? _validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El stock es requerido';
    }
    final stock = int.tryParse(value);
    if (stock == null) {
      return 'Ingresa un stock válido';
    }
    if (stock < 0) {
      return 'El stock no puede ser negativo';
    }
    if (stock > 999999) {
      return 'El stock no puede ser mayor a 999,999';
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
          child: LoadingOverlay(
            isLoading: _isLoading,
            loadingMessage: _isEditMode 
                ? 'Actualizando producto...' 
                : 'Creando producto...',
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppSizes.radiusL),
                        topRight: Radius.circular(AppSizes.radiusL),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.paddingL),
                      child: _buildForm(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: AppSizes.paddingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Editar Producto' : 'Agregar Producto',
                  style: AppTextStyles.heading2.copyWith(color: Colors.white),
                ),
                Text(
                  _isEditMode 
                      ? 'Modifica los datos del producto'
                      : 'Completa la información del producto',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSizes.paddingM),
          _buildFormHeader(),
          const SizedBox(height: AppSizes.paddingL),
          CustomTextField(
            label: AppStrings.productName,
            hint: 'Ej: iPhone 15 Pro',
            controller: _nameController,
            prefixIcon: Icons.inventory_2_outlined,
            validator: _validateName,
          ),
          const SizedBox(height: AppSizes.paddingM),
          CustomTextField(
            label: AppStrings.description,
            hint: 'Describe las características del producto',
            controller: _descriptionController,
            prefixIcon: Icons.description_outlined,
            maxLines: 3,
            validator: _validateDescription,
          ),
          const SizedBox(height: AppSizes.paddingM),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: AppStrings.price,
                  hint: '0.00',
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: Icons.attach_money,
                  validator: _validatePrice,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                child: CustomTextField(
                  label: AppStrings.stock,
                  hint: '0',
                  controller: _stockController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.warehouse_outlined,
                  validator: _validateStock,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
          _buildPreviewCard(),
          const SizedBox(height: AppSizes.paddingXL),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: AppStrings.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                  isOutlined: true,
                  backgroundColor: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSizes.paddingM),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: _isEditMode ? 'Actualizar' : AppStrings.save,
                  onPressed: _saveProduct,
                  icon: _isEditMode ? Icons.update : Icons.save,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingL),
        ],
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isEditMode ? Icons.edit : Icons.add_business,
            color: AppColors.primary,
            size: AppSizes.iconL,
          ),
          const SizedBox(width: AppSizes.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode ? 'Modo Edición' : 'Nuevo Producto',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _isEditMode 
                      ? 'Modifica los campos que desees actualizar'
                      : 'Completa todos los campos para crear el producto',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.onSurfaceVariant.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.preview,
                color: AppColors.info,
                size: AppSizes.iconM,
              ),
              const SizedBox(width: AppSizes.paddingS),
              Text(
                'Vista Previa',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingM),
          _buildPreviewRow('Nombre:', _nameController.text.isNotEmpty 
              ? _nameController.text : 'Nombre del producto'),
          _buildPreviewRow('Descripción:', _descriptionController.text.isNotEmpty 
              ? _descriptionController.text : 'Descripción del producto'),
          _buildPreviewRow('Precio:', _priceController.text.isNotEmpty 
              ? '\${_priceController.text}' : '\$0.00'),
          _buildPreviewRow('Stock:', _stockController.text.isNotEmpty 
              ? '${_stockController.text} unidades' : '0 unidades'),
          if (_priceController.text.isNotEmpty && _stockController.text.isNotEmpty)
            _buildPreviewRow(
              'Valor Total:', 
              '\${(double.tryParse(_priceController.text) ?? 0) * (int.tryParse(_stockController.text) ?? 0)}',
              isHighlighted: true,
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: isHighlighted 
                  ? AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    )
                  : AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}