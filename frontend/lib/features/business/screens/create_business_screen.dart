import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/business_model.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/repository_providers.dart';
import '../../../data/providers/dio_provider.dart';
import '../../auth/providers/auth_provider.dart';

// Provider for storage service
final _storageServiceProvider = Provider<StorageService>((ref) =>
    ref.watch(storageServiceProvider));

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() =>
      _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedBusinessType;
  String? _selectedCategoryId;
  List<BusinessCategoryModel> _categories = [];
  bool _isLoading = false;
  bool _slugEdited = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _slugController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _onNameChanged() {
    if (!_slugEdited) {
      final slug = _nameController.text
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'^-+|-+$'), '');
      _slugController.text = slug;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final businessRepo = ref.read(businessRepositoryProvider);
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getGenericToken() ?? await storage.getToken();
      final cats = await businessRepo.getCategories(token: token);
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final storage = ref.read(storageServiceProvider);
      final token = await storage.getGenericToken() ?? await storage.getToken();

      if (token == null) {
        _showError('Authentication token not found. Please log in again.');
        return;
      }

      final businessRepo = ref.read(businessRepositoryProvider);
      final business = await businessRepo.createBusiness(
        token: token,
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        businessType: _selectedBusinessType,
        categoryId: _selectedCategoryId,
        contactPhone: _phoneController.text.trim(),
        contactEmail: _emailController.text.trim(),
      );

      // Auto-select the new business
      await ref.read(authProvider.notifier).afterCreateBusiness(business);
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Business')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Business Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Business name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Slug
              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(
                  labelText: 'Slug (URL identifier)',
                  prefixIcon: Icon(Icons.link_rounded),
                  helperText: 'e.g. my-bakery (auto-generated from name)',
                ),
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
                onChanged: (_) => _slugEdited = true,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // auto-gen
                  final slug = v.trim();
                  if (slug.length < 2) return 'Slug must be at least 2 chars';
                  if (!RegExp(r'^[a-z0-9][a-z0-9-]*[a-z0-9]$')
                      .hasMatch(slug)) {
                    return 'Only lowercase letters, numbers, and hyphens';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Business Type
              DropdownButtonFormField<String>(
                value: _selectedBusinessType,
                decoration: const InputDecoration(
                  labelText: 'Business Type',
                  prefixIcon: Icon(Icons.store_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'single_branch', child: Text('Single Branch')),
                  DropdownMenuItem(
                      value: 'multi_branch', child: Text('Multi Branch')),
                ],
                onChanged: _isLoading
                    ? null
                    : (v) => setState(() => _selectedBusinessType = v),
              ),
              const SizedBox(height: 16),

              // Category
              if (_categories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Business Category',
                    prefixIcon: Icon(Icons.category_rounded),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() => _selectedCategoryId = v),
                ),
              if (_categories.isNotEmpty) const SizedBox(height: 16),

              // Contact Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  prefixIcon: Icon(Icons.phone_rounded),
                ),
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Contact Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  prefixIcon: Icon(Icons.email_rounded),
                ),
                keyboardType: TextInputType.emailAddress,
                enabled: !_isLoading,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _handleCreate(),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreate,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Create Business',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
