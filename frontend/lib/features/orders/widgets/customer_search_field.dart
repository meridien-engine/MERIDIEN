import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/customer_model.dart';
import '../../../data/providers/repository_providers.dart';

/// A search-as-you-type customer picker.
///
/// Shows a text field; on input (debounced 400 ms) calls
/// GET /customers?search=query and lists results below.
/// Tapping a result fires [onSelected] and collapses the list.
class CustomerSearchField extends ConsumerStatefulWidget {
  final CustomerModel? initialValue;
  final void Function(CustomerModel customer) onSelected;
  final void Function()? onCleared;
  final String? errorText;

  const CustomerSearchField({
    super.key,
    this.initialValue,
    required this.onSelected,
    this.onCleared,
    this.errorText,
  });

  @override
  ConsumerState<CustomerSearchField> createState() =>
      _CustomerSearchFieldState();
}

class _CustomerSearchFieldState extends ConsumerState<CustomerSearchField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  List<CustomerModel> _results = [];
  bool _loading = false;
  bool _showList = false;
  CustomerModel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Delay so a tap on a result row registers first.
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showList = false);
      });
    }
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _showList = false;
      });
      return;
    }
    _debounce =
        Timer(const Duration(milliseconds: 400), () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    setState(() => _loading = true);
    try {
      final customers = await ref
          .read(customerRepositoryProvider)
          .getCustomers(search: query, limit: 8);
      if (mounted) {
        setState(() {
          _results = customers;
          _loading = false;
          _showList = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _select(CustomerModel c) {
    setState(() {
      _selected = c;
      _showList = false;
      _controller.clear();
    });
    _focusNode.unfocus();
    widget.onSelected(c);
  }

  void _clear() {
    setState(() {
      _selected = null;
      _results = [];
      _showList = false;
      _controller.clear();
    });
    widget.onCleared?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    // ── Selected state: show chip ──────────────────────────────────────────
    if (_selected != null) {
      return InputDecorator(
        decoration: InputDecoration(
          labelText: 'Customer *',
          border: const OutlineInputBorder(),
          errorText: widget.errorText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Text(
                _selected!.fullName.isNotEmpty
                    ? _selected!.fullName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selected!.fullName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if ((_selected!.phone ?? '').isNotEmpty ||
                      _selected!.email.isNotEmpty)
                    Text(
                      [
                        if ((_selected!.phone ?? '').isNotEmpty)
                          _selected!.phone!,
                        if (_selected!.email.isNotEmpty) _selected!.email,
                      ].join(' · '),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: 'Change customer',
              onPressed: _clear,
            ),
          ],
        ),
      );
    }

    // ── Search state ───────────────────────────────────────────────────────
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            labelText: 'Search customer by name or phone *',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
            errorText: widget.errorText,
          ),
          onChanged: _onChanged,
        ),
        if (_showList) ...[
          const SizedBox(height: 4),
          _ResultsList(results: _results, onTap: _select),
        ],
      ],
    );
  }
}

class _ResultsList extends StatelessWidget {
  final List<CustomerModel> results;
  final void Function(CustomerModel) onTap;

  const _ResultsList({required this.results, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Text('No customers found',
            style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: results.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final c = results[i];
          final subtitle = [
            if ((c.phone ?? '').isNotEmpty) c.phone!,
            if (c.email.isNotEmpty) c.email,
            if ((c.company ?? '').isNotEmpty) c.company!,
          ].join(' · ');

          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: primary.withValues(alpha: 0.12),
              child: Text(
                c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : '?',
                style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            title: Text(c.fullName,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: subtitle.isNotEmpty
                ? Text(subtitle,
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[600]))
                : null,
            onTap: () => onTap(c),
          );
        },
      ),
    );
  }
}
