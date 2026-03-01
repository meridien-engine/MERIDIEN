import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/location_model.dart';
import '../providers/location_provider.dart';

class LocationManagementScreen extends ConsumerStatefulWidget {
  const LocationManagementScreen({super.key});

  @override
  ConsumerState<LocationManagementScreen> createState() =>
      _LocationManagementScreenState();
}

class _LocationManagementScreenState
    extends ConsumerState<LocationManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(locationProvider.notifier).listLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locations'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(locationProvider.notifier).listLocations(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLocationDialog(context),
        icon: const Icon(Icons.add_location_alt_rounded),
        label: const Text('Add Location'),
      ),
      body: Builder(builder: (context) {
        if (state.isLoading && state.locations.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.error),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(locationProvider.notifier).listLocations(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.locations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off_rounded,
                    size: 80, color: AppColors.textSecondary),
                const SizedBox(height: 16),
                Text(
                  'No locations yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add a city/zone with its shipping fee to get started.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(locationProvider.notifier).listLocations(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: state.locations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final location = state.locations[index];
              return _LocationTile(
                location: location,
                onEdit: () => _showLocationDialog(context, location: location),
                onDelete: () => _confirmDelete(context, location),
              );
            },
          ),
        );
      }),
    );
  }

  void _showLocationDialog(BuildContext context, {LocationModel? location}) {
    showDialog(
      context: context,
      builder: (_) => _LocationFormDialog(
        location: location,
        onSave: (city, zone, shippingFee) async {
          if (location == null) {
            // Create
            final result = await ref
                .read(locationProvider.notifier)
                .createLocation(CreateLocationRequest(
                  city: city,
                  zone: zone.isEmpty ? null : zone,
                  shippingFee: shippingFee,
                ));
            if (result != null && mounted) {
              _showSnack(context, 'Location created successfully', isError: false);
            } else if (mounted) {
              _showSnack(context,
                  ref.read(locationProvider).error ?? 'Failed to create location');
            }
          } else {
            // Update
            final result = await ref
                .read(locationProvider.notifier)
                .updateLocation(location.id,
                    UpdateLocationRequest(
                      city: city,
                      zone: zone.isEmpty ? null : zone,
                      shippingFee: shippingFee,
                    ));
            if (result != null && mounted) {
              _showSnack(context, 'Location updated successfully', isError: false);
            } else if (mounted) {
              _showSnack(context,
                  ref.read(locationProvider).error ?? 'Failed to update location');
            }
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, LocationModel location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Location'),
        content: Text(
            'Are you sure you want to delete "${location.displayName}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final ok =
          await ref.read(locationProvider.notifier).deleteLocation(location.id);
      if (mounted) {
        if (ok) {
          _showSnack(context, 'Location deleted', isError: false);
        } else {
          _showSnack(context,
              ref.read(locationProvider).error ?? 'Failed to delete location');
        }
      }
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : Colors.green,
      ),
    );
  }
}

// ─── Location Tile ─────────────────────────────────────────────────────────────

class _LocationTile extends StatelessWidget {
  final LocationModel location;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LocationTile({
    required this.location,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.12),
          child: Icon(Icons.location_on_rounded, color: AppColors.primary),
        ),
        title: Text(
          location.city,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          location.zone != null && location.zone!.isNotEmpty
              ? 'Zone: ${location.zone}'
              : 'No zone specified',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '\$${location.shippingFeeValue.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Edit',
              icon: const Icon(Icons.edit_rounded, size: 18),
              onPressed: onEdit,
            ),
            IconButton(
              tooltip: 'Delete',
              icon: Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.error),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location Form Dialog ──────────────────────────────────────────────────────

class _LocationFormDialog extends StatefulWidget {
  final LocationModel? location;
  final Future<void> Function(String city, String zone, String shippingFee)
      onSave;

  const _LocationFormDialog({this.location, required this.onSave});

  @override
  State<_LocationFormDialog> createState() => _LocationFormDialogState();
}

class _LocationFormDialogState extends State<_LocationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _cityCtrl;
  late final TextEditingController _zoneCtrl;
  late final TextEditingController _feeCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cityCtrl = TextEditingController(text: widget.location?.city ?? '');
    _zoneCtrl = TextEditingController(text: widget.location?.zone ?? '');
    _feeCtrl = TextEditingController(
        text: widget.location?.shippingFeeValue.toStringAsFixed(2) ?? '0.00');
  }

  @override
  void dispose() {
    _cityCtrl.dispose();
    _zoneCtrl.dispose();
    _feeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.location == null ? 'Add Location' : 'Edit Location'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _cityCtrl,
              decoration: const InputDecoration(
                labelText: 'City *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city_rounded),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'City is required';
                if (v.trim().length < 2) return 'City name too short';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _zoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Zone (optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.map_rounded),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _feeCtrl,
              decoration: const InputDecoration(
                labelText: 'Shipping Fee *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.local_shipping_rounded),
                prefixText: '\$ ',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Shipping fee is required';
                final parsed = double.tryParse(v.trim());
                if (parsed == null) return 'Enter a valid decimal number';
                if (parsed < 0) return 'Shipping fee cannot be negative';
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;
                  setState(() => _isSaving = true);
                  await widget.onSave(
                    _cityCtrl.text.trim(),
                    _zoneCtrl.text.trim(),
                    _feeCtrl.text.trim(),
                  );
                  if (mounted) {
                    setState(() => _isSaving = false);
                    Navigator.pop(context);
                  }
                },
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.location == null ? 'Create' : 'Save'),
        ),
      ],
    );
  }
}
