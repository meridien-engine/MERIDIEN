import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../services/storage_service.dart';
import '../../core/constants/api_endpoints.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add auth token interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storage = ref.read(storageServiceProvider);
        final token = await storage.getToken();

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        // Only clear session on token-level 401s (expired/invalid/revoked token).
        // Authorization failures from business-context checks (e.g. missing
        // business_id in context) should NOT wipe the scoped token.
        if (error.response?.statusCode == 401) {
          final body = error.response?.data;
          final errorMsg = (body is Map ? body['error'] ?? '' : '').toString().toLowerCase();
          final isTokenError = errorMsg.contains('token') ||
              errorMsg.contains('expired') ||
              errorMsg.contains('invalid') ||
              errorMsg.contains('unauthorized');
          if (isTokenError) {
            final storage = ref.read(storageServiceProvider);
            await storage.clearAll();
            // Navigation to login will be handled by router
          }
        }
        return handler.next(error);
      },
    ),
  );

  // Add logging interceptor (only in debug mode)
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
      maxWidth: 90,
      logPrint: (object) => print(object),
    ),
  );

  return dio;
});

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be overridden in ProviderScope');
});
