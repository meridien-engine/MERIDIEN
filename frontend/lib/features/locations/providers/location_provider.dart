import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/location_model.dart';
import '../../../data/repositories/location_repository.dart';
import '../../../data/providers/repository_providers.dart';

// ─── State ───────────────────────────────────────────────────────────────────

class LocationListState {
  final List<LocationModel> locations;
  final bool isLoading;
  final String? error;
  final int page;
  final int pageSize;
  final bool hasMore;

  const LocationListState({
    this.locations = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.pageSize = 50,
    this.hasMore = false,
  });

  LocationListState copyWith({
    List<LocationModel>? locations,
    bool? isLoading,
    String? error,
    int? page,
    int? pageSize,
    bool? hasMore,
    bool clearError = false,
  }) {
    return LocationListState(
      locations: locations ?? this.locations,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class LocationNotifier extends StateNotifier<LocationListState> {
  final LocationRepository _repository;

  LocationNotifier(this._repository) : super(const LocationListState());

  /// Load / reload all locations (page 1)
  Future<void> listLocations({int page = 1, int pageSize = 50}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _repository.listLocations(page: page, pageSize: pageSize);
      state = state.copyWith(
        locations: items,
        isLoading: false,
        page: page,
        pageSize: pageSize,
        hasMore: items.length >= pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new location and refresh the list
  Future<LocationModel?> createLocation(CreateLocationRequest request) async {
    try {
      final location = await _repository.createLocation(request);
      await listLocations();
      return location;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Update a location and refresh the list
  Future<LocationModel?> updateLocation(
      String id, UpdateLocationRequest request) async {
    try {
      final location = await _repository.updateLocation(id, request);
      await listLocations();
      return location;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Delete a location and refresh the list
  Future<bool> deleteLocation(String id) async {
    try {
      await _repository.deleteLocation(id);
      await listLocations();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Get a single location by id from cached state, or fetch from API
  LocationModel? getLocationById(String id) {
    try {
      return state.locations.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clear provider state (e.g. on workspace/tenant switch)
  void clearCache() {
    state = const LocationListState();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationListState>((ref) {
  final repository = ref.watch(locationRepositoryProvider);
  return LocationNotifier(repository);
});
