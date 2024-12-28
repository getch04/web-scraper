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

      // Cancel existing tasks if notifications are disabled
      if (settings?.notificationsEnabled == false) {
        await wm.Workmanager().cancelAll();
        return;
      }

      // Get user's preferred frequency
      final frequency = settings?.frequency ?? const Duration(minutes: 30);

      // Don't schedule if frequency is too short (workmanager minimum is 15 minutes)
      if (frequency < const Duration(minutes: 15)) {
        debugPrint('Frequency too short: ${frequency.inMinutes} minutes');
        return;
      }

      // Check when was the last fetch
      final lastFetch = await DatabaseService.instance.carListings
          .where()
          .sortByLastUpdatedDesc()
          .findFirst();

      if (lastFetch != null) {
        final timeSinceLastFetch =
            DateTime.now().difference(lastFetch.lastUpdated);
        if (timeSinceLastFetch < frequency) {
          debugPrint(
              'Skipping fetch - too soon (${timeSinceLastFetch.inMinutes} minutes since last fetch)');
          return;
        }
      }

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

      debugPrint(
          'Scheduled background fetch every ${frequency.inMinutes} minutes');
    } catch (e) {
      debugPrint('Failed to schedule periodic fetch: $e');
    }
  }

  static Future<void> handleBackground() async {
    try {
      final existingIsar = Isar.getInstance();
      if (existingIsar == null) {
        await DatabaseService.initialize();
      }

      final settings = await DatabaseService.getSettings();
      if (settings?.notificationsEnabled == false) return;

      // Check if enough time has passed since last fetch
      final lastFetch = await DatabaseService.instance.carListings
          .where()
          .sortByLastUpdatedDesc()
          .findFirst();

      if (lastFetch != null) {
        final timeSinceLastFetch =
            DateTime.now().difference(lastFetch.lastUpdated);
        final minInterval = settings?.frequency ?? const Duration(minutes: 30);

        if (timeSinceLastFetch < minInterval) {
          debugPrint('Skipping background fetch - too soon');
          return;
        }
      }

      // Continue with fetch if enough time has passed
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
    }
  }

  static Future<void> _handleNewListings(
    List<CarListing> newListings,
    List<CarListing> existingListings,
  ) async {
    try {
      final newCarsToAdd = <CarListing>[];

      // Create a set of existing detail page URLs for efficient lookup
      final existingUrls = existingListings.map((e) => e.detailPage).toSet();

      // Only process cars that don't exist in the database
      for (var newListing in newListings) {
        if (!existingUrls.contains(newListing.detailPage)) {
          newCarsToAdd.add(newListing);
        }
      }

      // If we found new cars, add them and notify
      if (newCarsToAdd.isNotEmpty) {
        // Add new cars to database
        await DatabaseService.instance.writeTxn(() async {
          for (var listing in newCarsToAdd) {
            await DatabaseService.instance.carListings.put(listing);
          }
        });

        // Notify user about new cars
        await NotificationService.showNotification(
          title: 'New Car Listings Available',
          body: 'Found ${newCarsToAdd.length} new car listings!',
          newListingsCount: newCarsToAdd.length,
        );

        debugPrint('Added ${newCarsToAdd.length} new car listings');
      }
    } catch (e) {
      debugPrint('Failed to handle new listings: $e');
    }
  }

  // Helper method to check if a listing has significant changes
  static bool _hasSignificantChanges(
      CarListing newListing, CarListing oldListing) {
    // Add conditions for what you consider significant changes
    return newListing.price != oldListing.price ||
        newListing.mileage != oldListing.mileage ||
        newListing.images.length != oldListing.images.length;
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  wm.Workmanager().executeTask((taskName, inputData) async {
    await BackgroundService.handleBackground();
    return true;
  });
}
