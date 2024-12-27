import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/providers/car_listing_provider.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../services/database_service.dart';

part 'filter_provider.g.dart';

@riverpod
class Filters extends _$Filters {
  final _isar = DatabaseService.instance;

  @override
  Stream<List<FilterIsar>> build() {
    return _isar.filterIsars.where().watch(fireImmediately: true);
  }

  Future<void> addFilter(FilterIsar filter) async {
    try {
      // Set loading state
      ref.read(carListingNotifierProvider.notifier).setLoading(true);

      final carListings =
          await ref.read(carListingNotifierProvider.notifier).fetchFromRemote(
                filter,
              );

      if (carListings.isEmpty) {
        ref.read(carListingNotifierProvider.notifier).setLoading(false);
        return;
      }

      await _isar.writeTxn(() async {
        await _isar.filterIsars.put(filter);

        // Check for duplicates when adding listings
        for (var listing in carListings) {
          final existingListing = await _isar.carListings
              .filter()
              .detailPageEqualTo(listing.detailPage)
              .findFirst();

          if (existingListing != null) {
            listing.id = existingListing.id;
          }

          await _isar.carListings.put(listing);
        }
      });

      // Reset loading state after operation is complete
      ref.read(carListingNotifierProvider.notifier).setLoading(false);
    } catch (e) {
      // Reset loading state on error
      ref.read(carListingNotifierProvider.notifier).setLoading(false);
      throw Exception(e);
    }
  }

  Future<void> toggleFilter(Id id) async {
    try {
      // Set loading state
      ref.read(carListingNotifierProvider.notifier).setLoading(true);

      late final bool wasActive;
      late final String hakuValue;

      await _isar.writeTxn(() async {
        final targetFilter = await _isar.filterIsars.get(id);
        if (targetFilter == null) {
          ref.read(carListingNotifierProvider.notifier).setLoading(false);
          return;
        }

        wasActive = targetFilter.isActive;
        hakuValue = targetFilter.hakuValue;

        // Toggle the target filter
        await _isar.filterIsars.put(
          targetFilter.copyWith(isActive: !wasActive),
        );

        // If the filter was turned off, remove its car listings
        if (wasActive) {
          await _isar.carListings.filter().filterEqualTo(hakuValue).deleteAll();
        }
      });

      // If the filter was turned on, fetch new data
      if (!wasActive) {
        await _fetchAllActiveFilters();
      } else {
        // If filter was turned off, refresh the UI
        await ref
            .read(carListingNotifierProvider.notifier)
            .fetchCarListingsFromDb();
      }

      // Reset loading state after operation is complete
      ref.read(carListingNotifierProvider.notifier).setLoading(false);
    } catch (e) {
      // Reset loading state on error
      ref.read(carListingNotifierProvider.notifier).setLoading(false);
      throw Exception(e);
    }
  }

  Future<void> deleteFilter(Id id) async {
    try {
      // Set loading state
      ref.read(carListingNotifierProvider.notifier).setLoading(true);

      await _isar.writeTxn(() async {
        // Delete associated car listings first
        final filter = await _isar.filterIsars.get(id);
        if (filter != null) {
          await _isar.carListings
              .filter()
              .filterEqualTo(filter.hakuValue)
              .deleteAll();
        }

        // Then delete the filter itself
        await _isar.filterIsars.delete(id);

        // Refresh car listings for remaining active filters
        await _fetchAllActiveFilters();
      });

      // Reset loading state after operation is complete
      ref.read(carListingNotifierProvider.notifier).setLoading(false);
    } catch (e) {
      // Reset loading state on error
      ref.read(carListingNotifierProvider.notifier).setLoading(false);
      throw Exception(e);
    }
  }

  // Helper method to fetch data for all active filters
  Future<void> _fetchAllActiveFilters() async {
    try {
      // Get all active filters
      final activeFilters =
          await _isar.filterIsars.filter().isActiveEqualTo(true).findAll();

      // Fetch remote data for each active filter
      for (final filter in activeFilters) {
        final carListings = await ref
            .read(carListingNotifierProvider.notifier)
            .fetchFromRemote(filter);

        if (carListings.isNotEmpty) {
          await _isar.writeTxn(() async {
            for (var listing in carListings) {
              final existingListing = await _isar.carListings
                  .filter()
                  .detailPageEqualTo(listing.detailPage)
                  .findFirst();

              if (existingListing != null) {
                listing.id = existingListing.id;
              }

              await _isar.carListings.put(listing);
            }
          });
        }
      }

      // Finally, refresh the UI with all fetched data
      await ref
          .read(carListingNotifierProvider.notifier)
          .fetchCarListingsFromDb();
    } catch (e) {
      throw Exception(e);
    }
  }
}
