import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/provider/car_listing_provider.dart';
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

      if (filter.isActive) {
        await ref.read(carListingNotifierProvider.notifier).fetchListings();
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> toggleFilter(Id id) async {
    await _isar.writeTxn(() async {
      final targetFilter = await _isar.filterIsars.get(id);
      if (targetFilter == null) return;

      if (!targetFilter.isActive) {
        final activeFilters =
            await _isar.filterIsars.filter().isActiveEqualTo(true).findAll();

        for (final filter in activeFilters) {
          await _isar.filterIsars.put(
            filter.copyWith(isActive: false),
          );
        }
      }

      await _isar.filterIsars.put(
        targetFilter.copyWith(isActive: !targetFilter.isActive),
      );

      await ref.read(carListingNotifierProvider.notifier).fetchListings();
    });
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
    });
  }
}
