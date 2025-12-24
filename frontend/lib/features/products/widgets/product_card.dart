import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  Color get _stockColor {
    if (product.isOutOfStock) return AppColors.error;
    if (product.isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 120,
              width: double.infinity,
              color: AppColors.primary.withOpacity(0.05),
              child: product.imageUrl != null
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // SKU
                    Text(
                      'SKU: ${product.sku}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const Spacer(),

                    // Price and Stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Text(
                          '\$${product.unitPrice}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),

                        // Stock Indicator
                        if (product.trackInventory)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _stockColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    // Stock Status Text
                    if (product.trackInventory) ...[
                      const SizedBox(height: 4),
                      Text(
                        product.stockStatus,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _stockColor,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }
}
