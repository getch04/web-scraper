import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/models/settings_isar.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static late Isar _isar;
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [CarListingSchema, FilterIsarSchema, SettingsIsarSchema],
        directory: dir.path,
      );
      _isInitialized = true;
    } catch (e) {
      if (e.toString().contains('already been opened')) {
        // If Isar is already open, get the instance
        _isar = Isar.getInstance()!;
        _isInitialized = true;
      } else {
        rethrow;
      }
    }
  }

  static Isar get instance => _isar;

  static Future<DateTime?> getLastFetchTime() async {
    final lastFetch =
        await _isar.carListings.where().sortByLastUpdatedDesc().findFirst();
    return lastFetch?.lastUpdated;
  }

  static Future<List<CarListing>> getExistingListings() async {
    return _isar.carListings.where().findAll();
  }

  static Future<void> updateListings(List<CarListing> listings) async {
    final now = DateTime.now();
    for (var listing in listings) {
      listing.lastUpdated = now;
    }

    await _isar.writeTxn(() async {
      await _isar.carListings.clear();
      await _isar.carListings.putAll(listings);
    });
  }

  static Future<void> deleteOldListings(int keepCount) async {
    await _isar.writeTxn(() async {
      final allListings =
          await _isar.carListings.where().sortByLastUpdatedDesc().findAll();

      if (allListings.length > keepCount) {
        final listingsToDelete = allListings.sublist(keepCount);
        await _isar.carListings
            .deleteAll(listingsToDelete.map((e) => e.id).toList());
      }
    });
  }

  //get settings
  static Future<SettingsIsar?> getSettings() async {
    return _isar.settingsIsars.filter().idEqualTo(0).findFirst();
  }
}
