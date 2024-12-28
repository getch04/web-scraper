// car_listing_provider.dart
import 'package:car_web_scrapepr/controllers/car_listing_state.dart';
import 'package:car_web_scrapepr/models/car_listing_isar.dart';
import 'package:car_web_scrapepr/models/filter_isar.dart';
import 'package:car_web_scrapepr/repo/car_listing_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'car_listing_provider.g.dart';

@riverpod
class CarListingNotifier extends _$CarListingNotifier {
  late final CarListingRepository _repository = CarListingRepository();
  bool _showNewestFirst = false;
  int _sortTimestamp = 0;
  static const pageSize = 2;

  CarListingRepository get repository => _repository;

  @override
  CarListingState build() {
    _repository.watchCarListings().listen((listings) {
      state = state.copyWith(
        listings: listings,
        isLoading: false,
      );
    });

    return const CarListingState();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setSortingPreference(
      {required bool showNewestFirst, int timestamp = 0}) {
    _showNewestFirst = showNewestFirst;
    _sortTimestamp = timestamp;
    // Re-sort current listings
    state = state.copyWith(
      listings: state.listings,
    );
  }

  // List<CarListing> _sortListings(List<CarListing> listings) {
  //   if (!_showNewestFirst) return listings;

  //   final sorted = List<CarListing>.from(listings);
  //   if (_sortTimestamp > 0) {
  //     // For listings after notification click, prioritize new listings
  //     sorted.sort((a, b) {
  //       final aIsNew = DateTime.now().millisecondsSinceEpoch - _sortTimestamp <
  //           60000; // Within 1 minute
  //       final bIsNew =
  //           DateTime.now().millisecondsSinceEpoch - _sortTimestamp < 60000;
  //       if (aIsNew != bIsNew) return aIsNew ? -1 : 1;
  //       return 0;
  //     });
  //   }
  //   return sorted;
  // }

  Future<void> fetchCarListingsFromDb() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final listings = await _repository.fetchCarListingsFromDb();
      state = state.copyWith(
        listings: listings,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  //fetch from remote
  Future<List<CarListing>> fetchFromRemote(
      [final FilterIsar? searchValue]) async {
    return await _repository.fetchFromNetwork(searchValue);
  }

  Future<List<CarListing>> fetchPage(int pageKey) async {
    try {
      final listings = await _repository.fetchPagedListings(
        page: pageKey,
        pageSize: pageSize,
      );
      return listings;
    } catch (e) {
      throw Exception('Failed to fetch listings: $e');
    }
  }
}
