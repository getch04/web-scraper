
import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/car_listing_model.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart' as wm;

import '../repo/car_listing_repository.dart';
import 'database_service.dart';
import 'notification_service.dart';

class BackgroundService {
  static const taskName = 'carListingsFetch';
  static const _fetchTimeout = Duration(minutes: 2);

  static Future<void> initialize() async {
    try {
      await wm.Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: true,
      );
      await schedulePeriodicFetch();
    } catch (e) {
      debugPrint('Failed to initialize background service: $e');
      rethrow;
    }
  }

  static Future<void> schedulePeriodicFetch() async {
    await wm.Workmanager().registerPeriodicTask(
      taskName,
      taskName,
      frequency: const Duration(minutes: 1),
      constraints: wm.Constraints(
        requiresBatteryNotLow: true,
        networkType: wm.NetworkType.connected,
      ),
      existingWorkPolicy: wm.ExistingWorkPolicy.append,
      backoffPolicy: wm.BackoffPolicy.linear,
      initialDelay: const Duration(seconds: 10),
    );
  }

  static Future<void> handleBackground() async {
    try {
      await DatabaseService.initialize();

      final repository = CarListingRepository();
      final Future<List<CarListing>> fetchFuture =
          repository.fetchCarListings(forceRefresh: true);

      final newListings = await fetchFuture.timeout(_fetchTimeout);
      final existingListings = await DatabaseService.getExistingListings();

      await _handleNewListings(newListings, existingListings);
    } catch (e, stackTrace) {
      debugPrint('Background fetch failed: $e\n$stackTrace');
    }
  }

  static Future<void> _handleNewListings(
    List<CarListing> newListings,
    List<CarListingIsar> existingListings,
  ) async {
    final newListingIds = newListings.map((l) => l.title).toSet();
    final existingListingIds = existingListings.map((l) => l.title).toSet();

    final newItems = newListingIds.difference(existingListingIds).length;

    // if (newItems > 0) {
    await NotificationService.showNotification(
      title: 'New Car Listings Available',
      body: 'Found $newItems new car listings!',
    );
    // }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((taskName, inputData) async {
    await BackgroundService.handleBackground();
    return true;
  });
}
