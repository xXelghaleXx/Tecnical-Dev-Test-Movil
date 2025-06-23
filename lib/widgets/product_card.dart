import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isOwner;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.isOwner = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.primary.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSizes.paddingS),
              _buildDescription(),
              const SizedBox(height: AppSizes.paddingM),
              _buildStats(),
              if (isOwner) ...[
                const SizedBox(height: AppSizes.paddingS),
                _buildActions(),
              ],
              const SizedBox(height: AppSizes.paddingS),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            product.name,
            style: AppTextStyles.heading3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingS,
            vertical: AppSizes.paddingXS,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppSizes.radiusS),
          ),
          child: Text(
            NumberFormat.currency(symbol: '\$').format(product.price),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      product.description,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.onSurfaceVariant,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.inventory_2_outlined,
            label: AppStrings.stock,
            value: product.stock.toString(),
            color: product.isInStock ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(width: AppSizes.paddingM),
        Expanded(
          child: _buildStatItem(
            icon: Icons.attach_money,
            label: AppStrings.totalValue,
            value: NumberFormat.currency(symbol: '\$').format(product.totalValue),
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: AppSizes.iconM,
          ),
          const SizedBox(height: AppSizes.paddingXS),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, size: AppSizes.iconS),
            label: const Text(AppStrings.edit),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSizes.paddingS),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: const Icon(Icons.delete, size: AppSizes.iconS),
            label: const Text(AppStrings.delete),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusS),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Icon(
          Icons.person,
          size: AppSizes.iconS,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppSizes.paddingXS),
        Text(
          product.username ?? 'Usuario desconocido',
          style: AppTextStyles.bodySmall,
        ),
        const Spacer(),
        Icon(
          Icons.access_time,
          size: AppSizes.iconS,
          color: AppColors.onSurfaceVariant,
        ),
        const SizedBox(width: AppSizes.paddingXS),
        Text(
          DateFormat('dd/MM/yyyy').format(product.createdAt),
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}