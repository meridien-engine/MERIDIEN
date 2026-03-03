import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/localization_extension.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/repository_providers.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final String? productId;
  final ProductModel? product;

  const ProductFormScreen({
    super.key,
    this.productId,
    this.product,
  });

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _costPriceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _stockQuantityController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();

  String? _categoryId;
  String _weightUnit = 'kg';
  bool _trackInventory = true;
  bool _isFeatured = false;
  String _status = 'active';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateForm(widget.product!);
    } else {
      _stockQuantityController.text = '0';
      _lowStockThresholdController.text = '10';
    }
  }

  void _populateForm(ProductModel product) {
    _nameController.text = product.name;
    _skuController.text = product.sku ?? '';
    _descriptionController.text = product.description ?? '';
    _categoryId = product.categoryId;
    _sellingPriceController.text = product.sellingPrice;
    _costPriceController.text = product.costPrice;
    _discountPriceController.text = product.discountPrice ?? '';
    _barcodeController.text = product.barcode ?? '';
    _trackInventory = product.trackInventory;
    _stockQuantityController.text = product.stockQuantity.toString();
    _lowStockThresholdController.text = product.lowStockThreshold.toString();
    _weightController.text = product.weight ?? '';
    _weightUnit = product.weightUnit;
    _notesController.text = product.notes ?? '';
    _status = product.status;
    _isFeatured = product.isFeatured;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _descriptionController.dispose();
    _sellingPriceController.dispose();
    _costPriceController.dispose();
    _discountPriceController.dispose();
    _barcodeController.dispose();
    _stockQuantityController.dispose();
    _lowStockThresholdController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(productRepositoryProvider);

      if (widget.product == null) {
        final request = CreateProductRequest(
          name: _nameController.text.trim(),
          sellingPrice: _sellingPriceController.text.trim(),
          sku: _skuController.text.trim().isEmpty ? null : _skuController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          categoryId: _categoryId,
          costPrice: _costPriceController.text.trim().isEmpty
              ? null
              : _costPriceController.text.trim(),
          discountPrice: _discountPriceController.text.trim().isEmpty
              ? null
              : _discountPriceController.text.trim(),
          barcode: _barcodeController.text.trim().isEmpty
              ? null
              : _barcodeController.text.trim(),
          trackInventory: _trackInventory,
          stockQuantity: int.tryParse(_stockQuantityController.text.trim()),
          lowStockThreshold: int.tryParse(_lowStockThresholdController.text.trim()),
          weight: _weightController.text.trim().isEmpty
              ? null
              : _weightController.text.trim(),
          weightUnit: _weightUnit,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        await repository.createProduct(request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.loc.productCreated)),
          );
          context.pop();
        }
      } else {
        final request = UpdateProductRequest(
          name: _nameController.text.trim() != widget.product!.name
              ? _nameController.text.trim()
              : null,
          sku: _skuController.text.trim() != (widget.product!.sku ?? '')
              ? (_skuController.text.trim().isEmpty ? null : _skuController.text.trim())
              : null,
          description: _descriptionController.text.trim() != (widget.product!.description ?? '')
              ? (_descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim())
              : null,
          categoryId: _categoryId != widget.product!.categoryId ? _categoryId : null,
          sellingPrice: _sellingPriceController.text.trim() != widget.product!.sellingPrice
              ? _sellingPriceController.text.trim()
              : null,
          costPrice: _costPriceController.text.trim() != widget.product!.costPrice
              ? (_costPriceController.text.trim().isEmpty ? null : _costPriceController.text.trim())
              : null,
          discountPrice: _discountPriceController.text.trim() != (widget.product!.discountPrice ?? '')
              ? (_discountPriceController.text.trim().isEmpty ? null : _discountPriceController.text.trim())
              : null,
          barcode: _barcodeController.text.trim() != (widget.product!.barcode ?? '')
              ? (_barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim())
              : null,
          trackInventory: _trackInventory != widget.product!.trackInventory ? _trackInventory : null,
          stockQuantity: _stockQuantityController.text.trim() != widget.product!.stockQuantity.toString()
              ? int.tryParse(_stockQuantityController.text.trim())
              : null,
          lowStockThreshold: _lowStockThresholdController.text.trim() != widget.product!.lowStockThreshold.toString()
              ? int.tryParse(_lowStockThresholdController.text.trim())
              : null,
          weight: _weightController.text.trim() != (widget.product!.weight ?? '')
              ? (_weightController.text.trim().isEmpty ? null : _weightController.text.trim())
              : null,
          weightUnit: _weightUnit != widget.product!.weightUnit ? _weightUnit : null,
          notes: _notesController.text.trim() != (widget.product!.notes ?? '')
              ? (_notesController.text.trim().isEmpty ? null : _notesController.text.trim())
              : null,
          status: _status != widget.product!.status ? _status : null,
          isFeatured: _isFeatured != widget.product!.isFeatured ? _isFeatured : null,
        );

        await repository.updateProduct(widget.product!.id, request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.loc.productUpdated)),
          );
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.loc.error}: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.product != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? context.loc.editProduct : context.loc.newProduct),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: _saveProduct,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Basic Information
            Text(
              context.loc.basicInformation,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${context.loc.productName} *',
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.loc.productNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _skuController,
              decoration: InputDecoration(
                labelText: context.loc.sku,
                border: const OutlineInputBorder(),
                hintText: context.loc.skuHint,
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: context.loc.description,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),

            TextFormField(
              initialValue: _categoryId,
              decoration: InputDecoration(
                labelText: context.loc.categoryIdOptional,
                hintText: context.loc.categoryIdHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => _categoryId = value.trim().isEmpty ? null : value.trim()),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _barcodeController,
              decoration: InputDecoration(
                labelText: context.loc.barcode,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Pricing
            Text(
              context.loc.pricing,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _sellingPriceController,
              decoration: InputDecoration(
                labelText: '${context.loc.sellingPrice} *',
                border: const OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.loc.sellingPriceRequired;
                }
                if (double.tryParse(value.trim()) == null) {
                  return context.loc.invalidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _costPriceController,
                    decoration: InputDecoration(
                      labelText: context.loc.costPrice,
                      border: const OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _discountPriceController,
                    decoration: InputDecoration(
                      labelText: context.loc.discountPriceShort,
                      border: const OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Inventory
            Text(
              context.loc.inventory,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: Text(context.loc.trackInventory),
              subtitle: Text(context.loc.trackInventorySubtitle),
              value: _trackInventory,
              onChanged: (value) => setState(() => _trackInventory = value),
            ),
            if (_trackInventory) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockQuantityController,
                      decoration: InputDecoration(
                        labelText: context.loc.stock,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lowStockThresholdController,
                      decoration: InputDecoration(
                        labelText: context.loc.lowStockAlert,
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // Physical Properties
            Text(
              context.loc.physicalProperties,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: context.loc.weight,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _weightUnit,
                    decoration: InputDecoration(
                      labelText: context.loc.unit,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(value: 'kg', child: Text(context.loc.kilogram)),
                      DropdownMenuItem(value: 'g', child: Text(context.loc.gram)),
                      DropdownMenuItem(value: 'lb', child: Text(context.loc.pound)),
                      DropdownMenuItem(value: 'oz', child: Text(context.loc.ounce)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _weightUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: context.loc.notes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Status & Visibility
            Text(
              context.loc.statusAndVisibility,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(
                labelText: context.loc.status,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'active', child: Text(context.loc.active)),
                DropdownMenuItem(value: 'draft', child: Text(context.loc.draft)),
                DropdownMenuItem(value: 'archived', child: Text(context.loc.archived)),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: Text(context.loc.featuredProduct),
              subtitle: Text(context.loc.featuredProductSubtitle),
              value: _isFeatured,
              onChanged: (value) => setState(() => _isFeatured = value),
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(isEditMode ? context.loc.updateProduct : context.loc.createProduct),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
