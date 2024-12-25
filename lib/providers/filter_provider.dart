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
      final carListings =
          await ref.read(carListingNotifierProvider.notifier).fetchFromRemote(
                filter,
              );

      if (carListings.isEmpty) return;

      await _isar.writeTxn(() async {
        await _isar.filterIsars.put(filter);

        // Check for duplicates when adding listings
        for (var listing
            in carListings.map((l) => CarListingIsar.fromCarListing(l))) {
          final existingListing = await _isar.carListingIsars
              .filter()
              .detailPageEqualTo(listing.detailPage)
              .findFirst();

          if (existingListing != null) {
            listing.id = existingListing.id;
          }

          await _isar.carListingIsars.put(listing);
        }
      });

      // Always fetch after adding a filter since it affects the active filters
      // await _fetchAllActiveFilters();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> toggleFilter(Id id) async {
    try {
      late final bool wasActive;
      late final String hakuValue;

      await _isar.writeTxn(() async {
        final targetFilter = await _isar.filterIsars.get(id);
        if (targetFilter == null) return;

        wasActive = targetFilter.isActive;
        hakuValue = targetFilter.hakuValue;

        // Toggle the target filter
        await _isar.filterIsars.put(
          targetFilter.copyWith(isActive: !wasActive),
        );

        // If the filter was turned off, remove its car listings
        if (wasActive) {
          await _isar.carListingIsars
              .filter()
              .filterEqualTo(hakuValue)
              .deleteAll();
        }
      });

      // If the filter was turned on, fetch new data
      if (!wasActive) {
        await _fetchAllActiveFilters();
      } 
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteFilter(Id id) async {
    await _isar.writeTxn(() async {
      // Delete associated car listings first
      final filter = await _isar.filterIsars.get(id);
      if (filter != null) {
        await _isar.carListingIsars
            .filter()
            .filterEqualTo(filter.hakuValue)
            .deleteAll();
      }

      // Then delete the filter itself
      await _isar.filterIsars.delete(id);

      // Refresh car listings for remaining active filters
      await _fetchAllActiveFilters();
    });
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
            for (var listing
                in carListings.map((l) => CarListingIsar.fromCarListing(l))) {
              final existingListing = await _isar.carListingIsars
                  .filter()
                  .detailPageEqualTo(listing.detailPage)
                  .findFirst();

              if (existingListing != null) {
                listing.id = existingListing.id;
              }

              await _isar.carListingIsars.put(listing);
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
