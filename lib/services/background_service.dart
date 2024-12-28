import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:workmanager/workmanager.dart' as wm;

import '../repo/car_listing_repository.dart';
import 'database_service.dart';
import 'notification_service.dart';

class BackgroundService {
  static const taskName = 'carListingsFetch';
  static const _fetchTimeout = Duration(minutes: 2);

  static Future<void> initialize() async {
    try {
      // First initialize database
      await DatabaseService.initialize();

      // Then initialize notifications
      await NotificationService.initialize();

      // Finally initialize workmanager
      await wm.Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Schedule periodic fetch only if everything else initialized successfully
      await schedulePeriodicFetch();
    } catch (e, stack) {
      debugPrint('Failed to initialize background service: $e\n$stack');
      // Don't rethrow - we want the app to continue even if background service fails
    }
  }

  static Future<void> schedulePeriodicFetch() async {
    try {
      final settings = await DatabaseService.getSettings();

      if (settings?.notificationsEnabled == false) {
        await wm.Workmanager().cancelAll();
        return;
      }

      final frequency = settings?.frequency ?? const Duration(minutes: 30);

      await wm.Workmanager().registerPeriodicTask(
        taskName,
        taskName,
        frequency: frequency,
        constraints: wm.Constraints(
          requiresBatteryNotLow: true,
          networkType: wm.NetworkType.connected,
        ),
        existingWorkPolicy: wm.ExistingWorkPolicy.replace,
        backoffPolicy: wm.BackoffPolicy.linear,
        initialDelay: const Duration(seconds: 10),
      );
    } catch (e) {
      debugPrint('Failed to schedule periodic fetch: $e');
      // Don't rethrow - periodic fetch can be retried later
    }
  }

  static Future<void> handleBackground() async {
    try {
      // Try to get existing Isar instance first
      final existingIsar = Isar.getInstance();
      if (existingIsar == null) {
        await DatabaseService.initialize();
      }

      final settings = await DatabaseService.getSettings();
      if (settings?.notificationsEnabled == false) return;

      // Get all active filters
      final activeFilters = await DatabaseService.instance.filterIsars
          .filter()
          .isActiveEqualTo(true)
          .findAll();

      if (activeFilters.isEmpty) return;

      final repository = CarListingRepository();
      final List<CarListing> allNewListings = [];

      // Fetch listings for each active filter
      for (final filter in activeFilters) {
        try {
          final listings =
              await repository.fetchFromNetwork(filter).timeout(_fetchTimeout);
          allNewListings.addAll(listings);
        } catch (e) {
          debugPrint('Failed to fetch listings for filter ${filter.name}: $e');
          continue; // Continue with next filter if one fails
        }
      }

      final existingListings = await DatabaseService.getExistingListings();
      await _handleNewListings(allNewListings, existingListings);
    } catch (e, stackTrace) {
      debugPrint('Background fetch failed: $e\n$stackTrace');
      // Don't rethrow - we want the background task to be considered successful
      // so it will be retried later
    }
  }

  static Future<void> _handleNewListings(
    List<CarListing> newListings,
    List<CarListing> existingListings,
  ) async {
    try {
      // Use detailPage URL as unique identifier
      final existingUrls = existingListings.map((e) => e.detailPage).toSet();
      final newUrls = newListings.map((e) => e.detailPage).toSet();

      final uniqueNewListings = newUrls
          .difference(existingUrls)
          .map((url) => newListings.firstWhere((l) => l.detailPage == url))
          .toList();

      if (uniqueNewListings.isNotEmpty) {
        // Save new listings to database
        await DatabaseService.instance.writeTxn(() async {
          for (var listing in uniqueNewListings) {
            await DatabaseService.instance.carListings.put(listing);
          }
        });

        // Show notification
        await NotificationService.showNotification(
          title: 'New Car Listings Available',
          body: 'Found ${uniqueNewListings.length} new car listings!',
          newListingsCount: uniqueNewListings.length,
        );
      }
    } catch (e) {
      debugPrint('Failed to handle new listings: $e');
      // Don't rethrow - we want the background task to be considered successful
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((taskName, inputData) async {
    await BackgroundService.handleBackground();
    return true;
  });
}
