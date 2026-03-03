import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/product_model.dart';
import '../../../data/providers/repository_providers.dart';

/// Opens a bottom sheet to search products by name, SKU, or barcode
/// and pick a quantity before adding to the order.
///
/// [onAdd] is called with the chosen product and quantity when the user
/// confirms. The sheet closes itself before calling [onAdd].
Future<void> showProductSearchPicker(
  BuildContext context, {
  required void Function(ProductModel product, int quantity) onAdd,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ProductSearchSheet(onAdd: onAdd),
  );
}

// ─────────────────────────────────────────────────────────────────────────────

class _ProductSearchSheet extends ConsumerStatefulWidget {
  final void Function(ProductModel, int) onAdd;

  const _ProductSearchSheet({required this.onAdd});

  @override
  ConsumerState<_ProductSearchSheet> createState() =>
      _ProductSearchSheetState();
}

class _ProductSearchSheetState extends ConsumerState<_ProductSearchSheet> {
  final _searchCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController(text: '1');
  Timer? _debounce;

  List<ProductModel> _results = [];
  bool _loading = false;
  String? _error;
  ProductModel? _selected;

  @override
  void initState() {
    super.initState();
    _loadDefault();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _qtyCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Load first 20 products so the list isn't empty on open.
  Future<void> _loadDefault() async {
    setState(() => _loading = true);
    try {
      final products =
          await ref.read(productRepositoryProvider).getProducts(limit: 20);
      if (mounted) setState(() {
        _results = products;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String q) {
    _debounce?.cancel();
    setState(() => _error = null);
    if (q.trim().isEmpty) {
      _loadDefault();
      return;
    }
    _debounce = Timer(
        const Duration(milliseconds: 400), () => _searchByName(q.trim()));
  }

  // GET /products?search=
  Future<void> _searchByName(String q) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final products = await ref
          .read(productRepositoryProvider)
          .getProducts(search: q, limit: 20);
      if (mounted) setState(() {
        _results = products;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // GET /products/lookup?q= (barcode / SKU exact match)
  Future<void> _lookupBarcode(String q) async {
    if (q.trim().isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final product = await ref
          .read(productRepositoryProvider)
          .lookupProduct(q.trim());
      if (mounted) setState(() {
        _results = [product];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() {
        _results = [];
        _loading = false;
        _error = 'No product found for "${q.trim()}"';
      });
    }
  }

  // ── Quantity helpers ──────────────────────────────────────────────────────

  int get _qty => int.tryParse(_qtyCtrl.text) ?? 1;
  int get _maxQty =>
      (_selected?.trackInventory ?? false) ? _selected!.stockQuantity : 9999;

  void _decrement() {
    if (_qty > 1) _qtyCtrl.text = (_qty - 1).toString();
  }

  void _increment() {
    if (_qty < _maxQty) _qtyCtrl.text = (_qty + 1).toString();
  }

  // ── Confirm ───────────────────────────────────────────────────────────────

  void _confirm() {
    final qty = _qty;
    if (qty <= 0) {
      _showError('Quantity must be at least 1');
      return;
    }
    if (_selected!.trackInventory && qty > _selected!.stockQuantity) {
      _showError('Only ${_selected!.stockQuantity} units in stock');
      return;
    }
    Navigator.pop(context);
    widget.onAdd(_selected!, qty);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ── Stock color ───────────────────────────────────────────────────────────

  Color _stockColor(ProductModel p) {
    if (!p.trackInventory) return Colors.grey;
    if (p.isOutOfStock) return Colors.red;
    if (p.isLowStock) return Colors.orange;
    return Colors.green;
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.inventory_2_rounded,
                    color: theme.colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Add Product',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Search field ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by name, SKU or barcode…',
                border: const OutlineInputBorder(),
                isDense: true,
                prefixIcon: _loading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_rounded),
                  tooltip: 'Lookup by barcode / SKU (exact)',
                  onPressed: () => _lookupBarcode(_searchCtrl.text),
                ),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: _lookupBarcode,
            ),
          ),

          if (_error != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Text(_error!,
                  style:
                      const TextStyle(color: Colors.red, fontSize: 13)),
            ),

          // ─────────────────────────────────────────────────────────────────
          // Product selected → quantity + confirm
          // ─────────────────────────────────────────────────────────────────
          if (_selected != null) ...[
            _SelectedProductCard(
              product: _selected!,
              stockColor: _stockColor(_selected!),
              onClear: () => setState(() => _selected = null),
            ),
            _QuantityRow(
              controller: _qtyCtrl,
              onDecrement: _decrement,
              onIncrement: _increment,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Add to Order'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

          // ─────────────────────────────────────────────────────────────────
          // Results list
          // ─────────────────────────────────────────────────────────────────
          ] else ...[
            if (_results.isEmpty && !_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No products found',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.42,
                ),
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  shrinkWrap: true,
                  itemCount: _results.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final p = _results[i];
                    return _ProductResultTile(
                      product: p,
                      stockColor: _stockColor(p),
                      onTap: p.isOutOfStock
                          ? null
                          : () => setState(() {
                                _selected = p;
                                _qtyCtrl.text = '1';
                              }),
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SelectedProductCard extends StatelessWidget {
  final ProductModel product;
  final Color stockColor;
  final VoidCallback onClear;

  const _SelectedProductCard({
    required this.product,
    required this.stockColor,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text('\$${product.displayPrice}',
                        style: TextStyle(
                            color: primary, fontWeight: FontWeight.w600)),
                    if (product.trackInventory)
                      Text('${product.stockQuantity} in stock',
                          style: TextStyle(
                              fontSize: 12, color: stockColor)),
                    if ((product.sku ?? '').isNotEmpty)
                      Text('SKU: ${product.sku}',
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[600])),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                label: const Text('Change'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityRow extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityRow({
    required this.controller,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Text('Quantity:',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onDecrement,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          SizedBox(
            width: 64,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 4),
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _ProductResultTile extends StatelessWidget {
  final ProductModel product;
  final Color stockColor;
  final VoidCallback? onTap;

  const _ProductResultTile({
    required this.product,
    required this.stockColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final disabled = onTap == null;

    final meta = [
      if ((product.sku ?? '').isNotEmpty) 'SKU: ${product.sku}',
      if ((product.barcode ?? '').isNotEmpty) '· ${product.barcode}',
    ].join(' ');

    return ListTile(
      dense: true,
      enabled: !disabled,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: (disabled ? Colors.grey : primary)
            .withValues(alpha: 0.1),
        child: Icon(
          Icons.inventory_2_outlined,
          size: 18,
          color: disabled ? Colors.grey : primary,
        ),
      ),
      title: Text(
        product.name,
        style: TextStyle(
            fontWeight: FontWeight.w600,
            color: disabled ? Colors.grey : null),
      ),
      subtitle: meta.isNotEmpty
          ? Text(meta,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]))
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('\$${product.displayPrice}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: stockColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.stockStatus,
              style: TextStyle(
                  fontSize: 10,
                  color: stockColor,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
