import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/analytics_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../../features/job/services/job_matching_service.dart';
import '../services/search_service.dart';
import '../services/connectivity_service.dart';
import '../services/caching_service.dart';
import '../../features/payment/services/payment_service.dart';

final serviceLocator = ProviderContainer();

// Core Services
final analyticsServiceProvider = Provider((ref) => AnalyticsService());
final storageServiceProvider = Provider((ref) => StorageService());
final notificationServiceProvider = Provider((ref) => NotificationService());
final cachingServiceProvider = Provider((ref) => CachingService());

// Feature Services
final paymentServiceProvider = Provider((ref) => PaymentService());
final jobMatchingServiceProvider = Provider((ref) => JobMatchingService());
final searchServiceProvider = Provider((ref) => SearchService());

class ServiceInitializer {
  static Future<void> initialize() async {
    final notificationService =
        serviceLocator.read(notificationServiceProvider);
    await notificationService.initialize();

    // Initialize other services that require async initialization
    // Connectivity service self-initializes in constructor
    serviceLocator.read(connectivityProvider.notifier);
  }
}
