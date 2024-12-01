import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/models/settings_isar.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseService {
  static late Isar _isar;

  static Future<void> initialize() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [CarListingIsarSchema, FilterIsarSchema, SettingsIsarSchema],
      directory: dir.path,
    );
  }

  static Isar get instance => _isar;

  static Future<DateTime?> getLastFetchTime() async {
    final lastFetch =
        await _isar.carListingIsars.where().sortByLastUpdatedDesc().findFirst();
    return lastFetch?.lastUpdated;
  }

  static Future<List<CarListingIsar>> getExistingListings() async {
    return _isar.carListingIsars.where().findAll();
  }

  static Future<void> updateListings(List<CarListingIsar> listings) async {
    await _isar.writeTxn(() async {
      await _isar.carListingIsars.clear();
      await _isar.carListingIsars.putAll(listings);
    });
  }
}
